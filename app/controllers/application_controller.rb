class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  
  before_action :require_user, :except => ['loginFacebook', 'loginGoogle']
  def require_user
    @session = Session.find_by(:auth_token => params[:auth_token])
    
    if !@session
      raise "Not Authenticated"
    end
    
    @user = @session.user
  end
  
  def send_notification(user, message)
    tokens = user.sessions.pluck(:onesignal_token)
    params = {"app_id" => "77e650eb-05ea-4214-acd9-ef9caf45cb06", 
      "contents" => {"en" => user.name + " : " + message.text},
      "include_player_ids" => tokens,
      "android_group" => message.from_id,
      "data" => {"message" => message},
      "large_icon" => URI.join(request.url, @user.get_image.imagefile.url).to_s }
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
