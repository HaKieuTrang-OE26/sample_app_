class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      check_activated user
    else
      flash.now[:danger] = t ".flash_danger_sessions"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def check_remember user
    if params[:session][:remember_me] == Settings.controller.one
      remember(user)
    else
      forget(user)
    end
  end

  def check_activated user
    if user.activated?
      log_in user
      check_remember user
      flash[:success] = t "sessions.check_activated.flash_success_sessions"
      redirect_back_or user
    else
      flash[:warning] = t "sessions.check_activated.flash_warning_sessions"
      redirect_to root_url
    end
  end
end
