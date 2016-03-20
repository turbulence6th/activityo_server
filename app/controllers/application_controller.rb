class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  
  before_action :require_user, :except => ['loginFacebook']
  def require_user
    @user = User.find_by(:auth_token => params['auth_token'])
  end
  
  def send_notification(onesignal_token, text)
    params = {"app_id" => "77e650eb-05ea-4214-acd9-ef9caf45cb06", 
          "contents" => {"en" => text},
    "include_player_ids" => [onesignal_token]}
    uri = URI.parse('https://onesignal.com/api/v1/notifications')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "Basic NjI2NmU4ZWUtMzk3Mi00YjA1LWJkOTMtNWM4ZTM3YmI5YTZi")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
end
