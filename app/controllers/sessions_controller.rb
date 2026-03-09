class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if session[:authenticated]
  end

  def create
    if ActiveSupport::SecurityUtils.secure_compare(params[:username].to_s, ENV.fetch("DASHBOARD_USERNAME", "admin")) &&
       ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, ENV.fetch("DASHBOARD_PASSWORD", "password"))
      session[:authenticated] = true
      redirect_to root_path
    else
      flash.now[:alert] = "ID 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:authenticated)
    redirect_to login_path
  end
end
