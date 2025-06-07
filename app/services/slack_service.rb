module SlackService
  def self.handle_params(parts)
    # Identify severity
    valid_severities = ['sev0', 'sev1', 'sev2']
    severity = valid_severities.include?(parts.last) ? parts.pop : 'sev1' 

    # Extract title and description 
    title = parts.shift 
    description = parts.join(" ") || nil

    [title, description, severity]
  end

  def self.slack_client
    @slack_client ||= Slack::Web::Client.new(token: ENV['SLACK_BOT_TOKEN'])
  end

  # a bot in each workspace should have its own team_id, this is to make sure that a bot is not creating or posting in a different
  def self.slack_client(team_id)
    token = Rails.cache.read("slack_#{team_id}_token")
  
    if token.nil?
      Rails.logger.error("❌ No stored access token for team #{team_id}")
      return nil
    end
  
    Slack::Web::Client.new(token: token)
  end

  def self.declare_incident(parts, slack_event)
    title, description, severity = handle_params(parts)
    user_id, user_name = slack_event.values_at('user_id', 'user_name')
    team_id = slack_event['team_id']
    
    slack_client_instance = slack_client(team_id)
    return unless slack_client_instance

    auth_response = slack_client_instance.auth_test
    if auth_response["ok"]
      bot_team_id = auth_response["team_id"]
      Rails.logger.info("✅ Bot authenticated in team: #{bot_team_id}")
      if bot_team_id != team_id
        Rails.logger.error("🚨 Mismatch! Expected team #{team_id}, but bot is in #{bot_team_id}")
        return
      end
    else
      Rails.logger.error("❌ Bot authentication failed: #{auth_response['error']}")
      return
    end

    incident = Incident.create!(title: title, description: description, severity: severity, creator: user_name)
    
    response = slack_client_instance.conversations_create(name: title)
    Rails.logger.info "Slack API Response: #{response.inspect}"
  
    return unless response['ok']

    # Get the Slack channel ID from the response
    slack_channel_id = response['channel']['id']

    incident.update!(slack_channel_id: slack_channel_id)

    # inviting the user to a new channel
    invite_response = slack_client_instance.conversations_invite(channel: slack_channel_id, users: user_id)

    # Post a summary of the incident in the new channel
    slack_client_instance.chat_postMessage(
    channel: slack_channel_id, 
    text: "🚨 *Incident Declared!* 🚨\n" \
    "*Title:* #{title}\n" \
    "*Description:* #{description || 'No description provided'}\n" \
    "*Severity:* #{severity}\n" \
    "*Declared by:* #{user_name}\n" \
    "_Join this channel to collaborate on resolving this issue._")
  end

  def self.resolve_incident(slack_event)
    channel_id = slack_event["channel_id"]

    team_id = slack_event["team_id"]

    slack_client_instance = slack_client(team_id)
    return unless slack_client_instance

    # Ensure bot is authenticated and belongs to the correct team
    auth_response = slack_client_instance.auth_test
    if auth_response["ok"]
      bot_team_id = auth_response["team_id"]
      Rails.logger.info("✅ Bot authenticated in team: #{bot_team_id}")

      if bot_team_id != team_id
        Rails.logger.error("🚨 Mismatch! Expected team #{team_id}, but bot is in #{bot_team_id}")
        return
      end
    else
      Rails.logger.error("❌ Bot authentication failed: #{auth_response['error']}")
      return
    end

    # Mark an incident as resolved in database
    incident = Incident.find_by(slack_channel_id: channel_id)
    return Rails.logger.error("❌ Incident not found for channel: #{channel_id}") unless incident

    incident.update(status: 'resolved', resolved_at: Time.current)

    # Post resolution message to Slack
    slack_client_instance.chat_postMessage(channel: channel_id, text: "✅ Incident resolved!")
  end
end

