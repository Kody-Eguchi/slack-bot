class SlackAuthController < ApplicationController
  def install
    slack_auth_url = "https://slack.com/oauth/v2/authorize?client_id=#{ENV['SLACK_CLIENT_ID']}&scope=commands,chat:write&redirect_uri=#{ENV['APP_HOST']}/slack/oauth/callback"
    redirect_to slack_auth_url
  end
end
