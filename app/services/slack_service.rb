class SlackService
  def self.slack_client
    @slack_client ||= Slack::Web::Client.new(token: ENV['SLACK_BOT_TOKEN'])
  end

  def self.declare_incident(title, description = nil, severity = nil, user_id, user_name)
    # Create an incident in database
    incident = Incident.create!(title: title, description: description, severity: severity, creator: user_name)
    
    # Create a new Slack channel for the incident
    response = slack_client.conversations_create(name: title)
  
    # Get the Slack channel ID from the response
    slack_channel_id = response['channel']['id']
    incident.update!(slack_channel_id: slack_channel_id)

    # inviting the user to a new channel
    slack_client.conversations_invite(channel: slack_channel_id, users: user_id)

    { response_type: 'in_channel', text: "Incident '#{title}' has been declared!" }

  end

  def self.resolve_incident(channel_id)

    # Mark an incident as resolved in database
    incident = Incident.find_by(slack_channel_id: channel_id)
    incident.update(status: 'resolved', resolved_at: Time.current)

    # Post resolution message to Slack
    slack_client.chat_postMessage(channel: channel_id, text: "Incident resolved!")
  end


end