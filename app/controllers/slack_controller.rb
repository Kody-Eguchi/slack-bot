class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def rootly
    if valid_slack_request?
      command = params[:command]
      title = params[:text]

      if command == '/rootly-declare'
        SlackService.declare_incident(title)
      elsif command == 'rootly-resolve'
        SlackService.resolve_incident(title)
      end
    end
  end

end
