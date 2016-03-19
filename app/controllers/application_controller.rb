class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  
  before_action :require_user, :except => ['loginFacebook']
  def require_user
    @user = User.find_by(:token => params['token'])
  end
  
end
