class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token
  
  before_action :require_user, :except => ['loginFacebook', 'loginGoogle', 'callback']
  def require_user
    @session = Session.find_by(:auth_token => params[:auth_token])
    
    if !@session
      respond_to do |format|
        format.json { render :json => { :require_session => true }, :status => 401 }
      end
      return
    end
    
    @user = @session.user
  end
  
  #Kullanıcıya mesaj gönder
  def send_notification_message_user(user, message)
    tokens = user.sessions.pluck(:gcmId)
    params = {"registration_ids" => tokens, 
      "data" => {"message" => message.text, "user_message" => message,
      "icon" => URI.join(request.url, @user.get_image.imagefile.url).to_s,
      "title" => @user.name} }
    uri = URI.parse('https://gcm-http.googleapis.com/gcm/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "key=AIzaSyCvGYE6wdKe7Fo0yQpY0BBLIbdYgWkItrc")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
  #Etkinliğe Kullanıcı Ekleme İsteği
  def send_notification_request(user, event)
    tokens = user.sessions.pluck(:gcmId)
    params = {"registration_ids" => tokens,
      "data" => {"message" => "#{@user.name} adlı kullanıcı #{event.name} adlı etkinliğinize katılmak istiyor", 
      "event_request" => true, 
      "title" => "Etkinlik Katılma İsteği"},
      "large_icon" => URI.join(request.url, @user.get_image.imagefile.url).to_s }
    uri = URI.parse('https://gcm-http.googleapis.com/gcm/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "key=AIzaSyCvGYE6wdKe7Fo0yQpY0BBLIbdYgWkItrc")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
  #Etkinliğe Kullanıcı Ekleme Onayı
  def send_notification_accept_request(user, event)
    tokens = user.sessions.pluck(:gcmId)
    params = {"registration_ids" => tokens, 
      "data" => {"message" => "#{event.name} adlı etkinliğe katılma isteğiniz onaylandı",
      "title" => "Etkinlik Katılma Onayı"},
      "large_icon" => URI.join(request.url, @user.get_image.imagefile.url).to_s }
    uri = URI.parse('https://gcm-http.googleapis.com/gcm/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "key=AIzaSyCvGYE6wdKe7Fo0yQpY0BBLIbdYgWkItrc")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
  #Arkadaş Olarak Ekleme İsteği
  def send_notification_add_friend(user)
    tokens = user.sessions.pluck(:gcmId)
    params = {"registration_ids" => tokens,  
      "data" => {"message" => "#{@user.name} adlı kullanıcı sizinle arkadaş olmak istiyor", 
      "friend_request" => true,
      "title" => "Arkadaşlık İsteği"},
      "large_icon" => URI.join(request.url, @user.get_image.imagefile.url).to_s }
    uri = URI.parse('https://gcm-http.googleapis.com/gcm/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "key=AIzaSyCvGYE6wdKe7Fo0yQpY0BBLIbdYgWkItrc")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
  #Arkadaş Olarak Ekleme Onayı
  def send_notification_accept_friend(user)
    tokens = user.sessions.pluck(:gcmId)
    params = {"registration_ids" => tokens, 
      "data" => {"message" => "#{@user.name} adlı kullanıcı arkadaşlık isteğinizi kabul etti",
      "title" => "Arkadaşlık Onayı"},
      "large_icon" => URI.join(request.url, @user.get_image.imagefile.url).to_s }
    uri = URI.parse('https://gcm-http.googleapis.com/gcm/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "key=AIzaSyCvGYE6wdKe7Fo0yQpY0BBLIbdYgWkItrc")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
end
