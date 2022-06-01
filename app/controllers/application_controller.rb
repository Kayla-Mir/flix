class ApplicationController < ActionController::Base
  add_flash_types(:danger)

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def current_user?(user)
    current_user == user
  end

  helper_method :current_user?

  def current_user_admin?
    current_user&.admin?
  end

  helper_method :current_user_admin?

  def require_signin
    unless current_user
      session[:intended_url] = request.url
      redirect_to new_session_url, alert: "You must be logged in."
    end
  end

  def require_admin
    unless current_user_admin?
      redirect_to movies_url, alert: "Unauthorized access!"
    end
  end
end
