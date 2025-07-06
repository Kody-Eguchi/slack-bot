class SlackAuthController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'


  ##############################################################################
  # Bot Installation Flow
  ##############################################################################
  def install_bot

    bot_scopes = %w[
      channels:join
      channels:manage
      channels:read
      channels:write.invites
      chat:write
      commands
      groups:write
      im:write
      mpim:write
      team:read
      users:read
      users:read.email
    ].join(',')

    user_scopes = %w[
      channels:read
      channels:write
      channels:write.invites
      chat:write
      groups:write
      im:write
      mpim:write
      users:read
      users:read.email
    ].join(',')

    slack_auth_url = "https://slack.com/oauth/v2/authorize?" +
                      "client_id=#{ENV['SLACK_CLIENT_ID']}&" +
                      "scope=#{bot_scopes}&" +
                      "user_scope=#{user_scopes}&" +
                      "redirect_uri=#{ENV['APP_HOST']}/slack/oauth/callback"        
    redirect_to slack_auth_url, allow_other_host: true
  end

  # Handle OAuth callback after user install the slack app
  def bot_callback
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
      # Store token
      team_id = data["team"]["id"]
      access_token = data["access_token"]

      Rails.cache.write("slack_#{team_id}_token", access_token)

      # Check Redis connection (Optional)
      redis = Redis.new(url: ENV['REDIS_URL'])
      redis_connection_status = redis.ping
      Rails.logger.info("Redis connection check: #{redis_connection_status}")

      # render json: { message: "Slack app installed successfully!", team: data["team"]["name"] }
      render :index, locals: { team_name: data["team"]["name"] }
    else
      render json: { error: data["error"] }, status: :unauthorized
    end
  end

  ##############################################################################
  # User Auth Flow
  ##############################################################################

  def start_user_auth
    user_scopes = %w[
      users:read
      users:read.email
    ].join(',')

    slack_auth_url = "https://slack.com/oauth/v2/authorize?" +
                     "client_id=#{ENV['SLACK_CLIENT_ID']}&" +
                     "scope=#{user_scopes}&" +
                     "redirect_uri=#{ENV['APP_HOST']}/auth/slack/callback" +
                     "&user_scope=#{user_scopes}"
    redirect_to slack_auth_url, allow_other_host: true
  end

  def user_callback
    code = params[:code]
    Rails.logger.debug "🚨 Slack callback code: #{code.inspect}"

    if code.blank?
      Rails.logger.error "🚨 Authorization code missing!"
      redirect_to root_path, alert: "Authorization code missing."
      return
    end

    uri = URI("https://slack.com/api/oauth.v2.access")
    response = Net::HTTP.post_form(uri, {
      client_id: ENV["SLACK_CLIENT_ID"],
      client_secret: ENV["SLACK_CLIENT_SECRET"],
      code: code,
      redirect_uri: "#{ENV["APP_HOST"]}/auth/slack/callback"
    })

    data = JSON.parse(response.body)
    Rails.logger.debug "🚨 Slack oauth.v2.access response: #{data.inspect}"

    unless data["ok"]
      Rails.logger.error "🚨 Slack auth failed: #{data['error']}"
      redirect_to root_path, alert: "Slack auth failed: #{data['error']}"
      return
    end

    user_token = data["authed_user"]["access_token"]
    user_id    = data["authed_user"]["id"]
    Rails.logger.debug "🚨 User access token: #{user_token.inspect}" 
    Rails.logger.debug "🚨 User ID: #{user_id.inspect}"          

    # Fetch user info with the user token
    user_info_uri = URI("https://slack.com/api/users.info?user=#{user_id}")
    req = Net::HTTP::Get.new(user_info_uri)
    req["Authorization"] = "Bearer #{user_token}"

    res = Net::HTTP.start(user_info_uri.hostname, user_info_uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    user_info = JSON.parse(res.body)
    Rails.logger.debug "🚨 Slack users.info response: #{user_info.inspect}"  

    unless user_info["ok"]
      redirect_to root_path, alert: "Could not fetch user info: #{user_info['error']}"
      return
    end

    slack_user = user_info["user"]
    slack_email = slack_user.dig("profile", "email")
    slack_name = slack_user["name"]
    slack_id = slack_user["id"]


    # Find or create user record in your DB
    user = User.find_or_initialize_by(provider: "slack", uid: slack_id)
    user.email = slack_email
    user.slack_user_name = slack_name
    user.slack_user_id = slack_id
    user.password ||= Devise.friendly_token[0, 20]
    user.save!

    if user.save
      Rails.logger.info "✅ User saved successfully: #{user.inspect}"  
      sign_in_and_redirect user, event: :authentication
    else
      Rails.logger.error "🚨 Failed to save user: #{user.errors.full_messages.join(', ')}"  
      redirect_to new_user_registration_url, alert: "Could not save user: #{user.errors.full_messages.join(', ')}"
    end
  end

end
