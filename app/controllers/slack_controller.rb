class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def rootly
    text = params[:text]
    return render json: { response_type: 'ephemeral', text: "Invalid command format." }, status: :bad_request if text.blank?
    parts = text.split(" ")
    command = parts.shift

    puts "command #{command}"
    case command
    when 'declare'
      title, description, severity = handle_params(parts)
      SlackService.declare_incident(title, description, severity)
      render json: { response_type: 'ephemeral', text: "Incident '#{title}' declared with severity #{severity}." }
    when 'resolve'
      title = parts.join(" ")
      SlackService.resolve_incident(incident_id)
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
