class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :require_login

  private

  def require_login
    unless session[:authenticated]
      redirect_to login_path
    end
  end
end
