class OauthsController < ApplicationController

  # skip_before_filter :require_login

  # Sends the user on a trip to the provider
  #   and after authorizing there back to the callback url.
  def oauth
    login_at(params[:provider])
    binding.remote_pry
  end

  def callback
    provider = params[:provider]

    if @user = login_from(provider)
      redirect_back_or_to root_path, notice: "Logged in from #{ provider.titleize }!"
    else

      begin
        @user = create_from(provider)

        reset_session # protect from session fixation attack
        auto_login(@user)
        redirect_back_or_to root_path, notice: "Logged in from #{ provider.titleize }!"
      rescue
        redirect_back_or_to root_path, alert: "Failed to login from #{ provider.titleize }!"
      end

    end
  end
end
