class SlackService
  include SlackHelper

  def self.slack_client
    @slack_client ||= Slack::Web::Client.new(token: ENV['SLACK_BOT_TOKEN'])
  end

  def self.declare_incident(parts, slack_event)
    title, description, severity = new.handle_params(parts)
    user_id, user_name = slack_event.values_at('user_id', 'user_name')
    
    Rails.logger.info "User Info: User ID: #{user_id}, User Name: #{user_name}"
    Rails.logger.info "Slack Event: #{slack_event.inspect}"

    # Create an incident in database
    incident = Incident.create!(title: title, description: description, severity: severity, creator: user_name)
    
    # Create a new Slack channel for the incident
    response = slack_client.conversations_create(name: title)

    Rails.logger.info "Slack API Response: #{response.inspect}"

    # Check bot's membership in the newly created channel
    slack_channel_id = response['channel']['id']
    channel_info = slack_client.conversations_info(channel: slack_channel_id)

    auth_response = slack_client.auth_test
    bot_user_id = auth_response['user_id']
    
   
      invite_response = slack_client.conversations_invite(channel: slack_channel_id, users: bot_user_id)
      Rails.logger.info "Bot Invite Response: #{invite_response.inspect}"
    

    auth_response = slack_client.auth_test
    if auth_response["ok"]
      Rails.logger.info("🚨🚨🚨Authenticated Slack user: #{auth_response['user']}")
    else
      Rails.logger.error("🚨🚨🚨Slack authentication failed: #{auth_response['error']}")
    end

    channels_response = slack_client.conversations_list
    channels = channels_response['channels']
    Rails.logger.info("List of channels in the workspace: #{channels.map { |channel| channel['name'] }.join(', ')}")
  
    # Get the Slack channel ID from the response
    slack_channel_id = response['channel']['id']
    incident.update!(slack_channel_id: slack_channel_id)

    # inviting the user to a new channel
    Rails.logger.info "User ID before inviting: #{user_id.inspect}"
    invite_response = slack_client.conversations_invite(channel: slack_channel_id, users: user_id)
    Rails.logger.info "Slack Invite Response: #{invite_response.inspect}"

    # Post a summary of the incident in the new channel
    slack_client.chat_postMessage(channel: slack_channel_id, 
    text: "🚨 *Incident Declared!* 🚨\n" \
    "*Title:* #{title}\n" \
    "*Description:* #{description || 'No description provided'}\n" \
    "*Severity:* #{severity}\n" \
    "*Declared by:* #{user_name}\n" \
    "_Join this channel to collaborate on resolving this issue._")
  end

  def self.resolve_incident(slack_event)
    channel_id = slack_event["channel_id"]
    # Mark an incident as resolved in database
    incident = Incident.find_by(slack_channel_id: channel_id)
    incident.update(status: 'resolved', resolved_at: Time.current)
    # Post resolution message to Slack
    slack_client.chat_postMessage(channel: channel_id, text: "Incident resolved!")
  end


end

