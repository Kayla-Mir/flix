class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email_or_username]) ||
      User.find_by(username: params[:email_or_username])
    if user && user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to (session[:intended_url] || user),
        notice: "Welcome back, #{user.name}!"
      session[:intended_url] = nil
    else
      flash.now[:alert] = "Invalid email or password."
      render :new
    end
  end

  def destroy
    # binding.pry
    session[:user_id] = nil
    redirect_to movies_url, notice: "You have been signed out."
  end
end
