class SlackAuthController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  # From my application endpoint redirect user to Slack OAuth page
  def install
    slack_auth_url = "https://slack.com/oauth/v2/authorize?" +
                     "client_id=#{ENV['SLACK_CLIENT_ID']}&" +
                     "scope=commands,chat:write&" +
                     "redirect_uri=#{ENV['APP_HOST']}/slack/oauth/callback"
    redirect_to slack_auth_url, allow_other_host: true
  end

  # Handle OAuth callback after user install the slack app
  def callback
    code = params[:code]

    if code.blank?
      render json: { error: "Authorization code missing" }, status: :bad_request
      return
    end

    # Exchange the code for an access token
    uri = URI("https://slack.com/api/oauth.v2.access")
    response = Net::HTTP.post_form(uri, {
      client_id: ENV["SLACK_CLIENT_ID"],
      client_secret: ENV["SLACK_CLIENT_SECRET"],
      code: code,
      redirect_uri: "#{ENV["APP_HOST"]}/slack/oauth/callback"
    })

    data = JSON.parse(response.body)

    if data["ok"]
      # Store token - Render does not has a built-in cache storage...
      team_id = data["team"]["id"]
      access_token = data["access_token"]

      Rails.cache.write("slack_#{team_id}_token", access_token)

      render json: { message: "Slack app installed successfully!", team: data["team"]["name"] }
    else
      render json: { error: data["error"] }, status: :unauthorized
    end
  end


end
