class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def flag
    text = params[:text]
    return render json: { response_type: 'ephemeral', text: "Invalid command format." }, status: :bad_request if text.blank?
    parts = text.split(" ")
    command = parts.shift

    # Retrieve an event data of the request (contains user ID)
    slack_event = params.to_unsafe_h
    
    # Case statement to handle commnand 
    case command
    when 'declare'
      SlackService.declare_incident(parts, slack_event)
      render json: { response_type: 'ephemeral', text: "Incident declared" }
    when 'resolve'
      SlackService.resolve_incident(slack_event)
    else
      render json: { response_type: 'ephemeral', text: "Unknown command: #{command}" }, status: :bad_request
    end
  end

end
