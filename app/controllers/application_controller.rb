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
  
  def gcmPushNotification(params)
    uri = URI.parse('https://gcm-http.googleapis.com/gcm/send')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-Type'  => 'application/json',
                                  'Authorization' => "key=AIzaSyCvGYE6wdKe7Fo0yQpY0BBLIbdYgWkItrc")
    request.body = params.as_json.to_json
    response = http.request(request) 
  end
  
  #Kullanıcıya mesaj gönder
  def send_notification_message_user(user, message)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens, 
      "data" => {"message" => message['text'], "user_message" => message,
        "title" => @user.name}
    }
    gcmPushNotification(params)
  end
  
  #Etkinlik Chat Mesajı
  def send_notification_message_event(event, message)
    tokens = Session.from('joins, sessions')
      .where("joins.event_id=? AND joins.allowed=true AND joins.user_id!=? AND " + 
        "joins.user_id=sessions.user_id", 
        event.id, message['from_id']).where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken) 
    params = {"registration_ids" => tokens, 
      "data" => {"message" => message['text'], "user_message" => message,
        "title" => event.name
       } 
    }
    gcmPushNotification(params)
  end
  
  #Etkinliğe Kullanıcı Ekleme İsteği
  def send_notification_request(user, event)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens,
      "data" => {"message" => "#{@user.name} adlı kullanıcı #{event.name} adlı etkinliğinize katılmak istiyor", 
        "event_request" => true, 
        "title" => "Etkinlik Katılma İsteği"
      } 
    }
    gcmPushNotification(params)
  end
  
  #Etkinlik Kullanıcı İptal
  def send_notification_withdraw(user, event)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens,
      "data" => { 
        "event_request" => true
      } 
    }
    gcmPushNotification(params)
  end
  
  #Etkinliğe Kullanıcı Ekleme Onayı
  def send_notification_accept_request(user, event)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens, 
      "data" => {"message" => "#{event.name} adlı etkinliğe katılma isteğiniz onaylandı",
        "title" => "Etkinlik Katılma Onayı"
      }
    }
    gcmPushNotification(params)
  end
  
  #Takip Olarak Ekleme İsteği
  def send_notification_follow_user(user)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens,  
      "data" => {"message" => "#{@user.name} adlı kullanıcı sizi takip etmek istiyor", 
        "follow_request" => true,
        "title" => "Takip İsteği"
      } 
    }
    gcmPushNotification(params)
  end
  
  #Takip İptal
  def send_notification_cancel_follow(user)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens,  
      "data" => {
        "follow_request" => true
      } 
    }
    gcmPushNotification(params)
  end
  
  #Takip Olarak Ekleme Onayı
  def send_notification_accept_follow(user)
    tokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => tokens, 
      "data" => {"message" => "#{@user.name} adlı kullanıcı takip etme isteğinizi onayladı",
        "title" => "Takip Onayı"
      }
    }
    gcmPushNotification(params)
  end
  
end
