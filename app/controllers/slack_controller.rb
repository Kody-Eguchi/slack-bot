class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def rootly
    text = params[:text]
    return render json: { response_type: 'ephemeral', text: "Invalid command format." }, status: :bad_request if text.blank?
    parts = text.split(" ")
    command = parts.shift

    # Retrieve an event data of the request (contains user ID)
    slack_event = params.to_unsafe_h

   
    
    case command
    when 'declare'
      title, description, severity = handle_params(parts)
      user_id = slack_event['user_id']
      user_name = slack_event['user_name']
      SlackService.declare_incident(title, description, severity, user_id, user_name)
      render json: { response_type: 'ephemeral', text: "Incident '#{title}' declared with severity #{severity}." }
    when 'resolve'
      channel_id = slack_event["channel_id"]
      SlackService.resolve_incident(channel_id)
      render json: { response_type: 'ephemeral', text: " This incident has been resolved." }
    else
      render json: { response_type: 'ephemeral', text: "Unknown command: #{command}" }, status: :bad_request
    end

      


  end
  


    private

    def handle_params(parts)
      # Identify severity
      valid_severities = ['sev0', 'sev1', 'sev2']
      severity = valid_severities.include?(parts.last) ? parts.pop : 'sev1' 
  
      # Extract title and description 
      title = parts.shift 
      description = parts.join(" ") || nil
  
      [title, description, severity]
    end

end
