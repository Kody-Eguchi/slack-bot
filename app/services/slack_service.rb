class SlackService
  def self.slack_client
    @slack_client ||= Slack::Web::Client.new(token: ENV('SLACK_BOT_TOKEN'))
  end

  def self.declare_incident(title, description = nil, serverity = nil)
    # Create an incident in database
    Incident.create!(title: title, description: description, serverity: serverity)
    
    # Create a new Slack channel for the incident
    slack_client.conversations_create(name: title)

  end

  def self.resolve_incident(incident_id)
    # Mark an incident as resolved in database
    incident = Incident.find(incident_id)
    incident.update(status: 'resolved')

    # Post resolution message to Slack
    slack_client.chat_postMessage(channel: incident.channel, text: "Incident resolved!")
  end


end