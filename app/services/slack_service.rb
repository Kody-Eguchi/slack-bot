class SlackService
  def self.slack_client
    @slack_client ||= Slack::Web::Client.new(token: ENV['SLACK_BOT_TOKEN'])
  end

  def self.declare_incident(title, description = nil, severity = nil, user)
    # Create an incident in database
    incident = Incident.create!(title: title, description: description, severity: severity, creator: "user1")
    
    # Create a new Slack channel for the incident
    response = slack_client.conversations_create(name: title)
  
    # Get the Slack channel ID from the response
    slack_channel_id = response['channel']['id']
    incident.update!(slack_channel_id: slack_channel_id)

    # inviting the user to a new channel
    slack_client.conversations_invite(channel: slack_channel_id, users: user)

    { response_type: 'in_channel', text: "Incident '#{title}' has been declared!" }

  end

  def self.resolve_incident(incident_id)


    # identify current channel_id


    # Mark an incident as resolved in database
    incident = Incident.find(incident_id)
    incident.update(status: 'resolved')

    # Post resolution message to Slack
    slack_client.chat_postMessage(channel: incident.channel, text: "Incident resolved!")
  end


end