class OmniauthCallbacksController < ApplicationController
  def slack
    auth = request.env["omniauth.auth"]
    Rails.logger.debug "SLACK AUTH DATA 🚨🚨🚨🚨: #{auth.inspect}"
    puts "🚨🚨🚨🚨"

    # Try to find user by provider and uid
    @user = User.find_by(provider: auth.provider, uid: auth.uid)
    
    if @user.nil?
      # User not found, create a new one
      @user = User.new(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      slack_user_name: auth.info.name,
      slack_user_id: auth.uid,
      password: Devise.friendly_token[0, 20]
    )
    else
      # Update existing user info if needed
      @user.email = auth.info.email if @user.email.blank?
      @user.slack_user_name = auth.info.name
      @user.slack_user_id = auth.uid
    end

    if @user.save
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Slack") if is_navigational_format?
    else
      session["devise.slack_data"] = auth.except("extra") # remove extra for session size limits
      redirect_to new_user_registration_url, alert: "Slack authentication failed."
    end
  end

  def failure
    redirect_to root_path, alert: "Slack authentication failed."
  end
end
