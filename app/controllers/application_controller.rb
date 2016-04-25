class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token
  
  before_action :require_user, :except => ['loginFacebook', 'loginGoogle']
  def require_user
    @session = Session.find_by(:auth_token => params[:auth_token])
    
    if !@session
      raise "Not Authenticated"
    end
    
    @user = @session.user
  end
  
  #Kullanıcıya mesaj gönder
  def send_notification_message_user(user, message)
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
  
  #Etkinliğe Kullanıcı Ekleme İsteği
  def send_notification_request(user, event)
    tokens = user.sessions.pluck(:onesignal_token)
    params = {"app_id" => "77e650eb-05ea-4214-acd9-ef9caf45cb06", 
      "contents" => {"en" => "#{user.name} adlı kullanıcı #{event.name} adlı etkinliğinize katılmak istiyor"},
      "include_player_ids" => tokens,
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
  
  #Etkinliğe Kullanıcı Ekleme Onayı
  def send_notification_accept_request(user, event)
    tokens = user.sessions.pluck(:onesignal_token)
    params = {"app_id" => "77e650eb-05ea-4214-acd9-ef9caf45cb06", 
      "contents" => {"en" => "#{event.name} adlı etkinliğe katılma isteğiniz onaylandı"},
      "include_player_ids" => tokens,
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
  
  #Arkadaş Olarak Ekleme İsteği
  def send_notification_add_friend(user)
    tokens = user.sessions.pluck(:onesignal_token)
    params = {"app_id" => "77e650eb-05ea-4214-acd9-ef9caf45cb06", 
      "contents" => {"en" => "#{@user.name} adlı kullanıcı sizinle arkadaş olmak istiyor"},
      "include_player_ids" => tokens,
      "data" => {"friend_request" => true},
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
  
  #Arkadaş Olarak Ekleme Onayı
  def send_notification_accept_friend(user)
    tokens = user.sessions.pluck(:onesignal_token)
    params = {"app_id" => "77e650eb-05ea-4214-acd9-ef9caf45cb06", 
      "contents" => {"en" => "#{@user.name} adlı kullanıcı arkadaşlık isteğinizi kabul etti"},
      "include_player_ids" => tokens,
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
