class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token
  
  before_action :require_user, :except => ['loginFacebook', 'loginGoogle', 'callback']
  
  APN = Houston::Client.development
  APN.certificate = File.read(Rails.root.to_s + "/config/activityoiospush.pem")
  APN.passphrase = "1559o8663"
    
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
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens, 
      "data" => {"message" => message['text'], "user_message" => message,
        "title" => @user.name}
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => "#{@user.name}: #{message['text']}", :badge => 1, :sound => 'default')
      notification.content_available = true
      notification.custom_data = {"user_message" => message.to_json}
      APN.push(notification)
    end
  end
  
  #Etkinlik Chat Mesajı
  def send_notification_message_event(event, message)
    gcmTokens = Session.from('joins, sessions')
      .where("joins.event_id=? AND joins.allowed=true AND joins.user_id!=? AND " + 
        "joins.user_id=sessions.user_id", 
        event.id, message['from_id']).where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken) 
    params = {"registration_ids" => gcmTokens, 
      "data" => {"message" => message['text'], "user_message" => message,
        "title" => event.name
       } 
    }
    gcmPushNotification(params)
    
    apnsTokens = Session.from('joins, sessions')
      .where("joins.event_id=? AND joins.allowed=true AND joins.user_id!=? AND " + 
        "joins.user_id=sessions.user_id", 
        event.id, message['from_id']).where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken) 
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => "#{event.name}: #{message['text']}", :badge => 1, :sound => 'default')
      notification.content_available = true
      notification.custom_data = {"user_message" => message.to_json}
      APN.push(notification)
    end
  end
  
  #Etkinliğe Kullanıcı Ekleme İsteği
  def send_notification_request(user, event)
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens,
      "data" => {"message" => "#{@user.name} adlı kullanıcı #{event.name} adlı aktivitenize katılmak istiyor", 
        "event_request" => true, 
        "title" => "Etkinlik Katılma İsteği"
      } 
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => "#{@user.name} adlı kullanıcı #{event.name} adlı aktivitenize katılmak istiyor", 
        :badge => 1, :sound => 'default')
      notification.content_available = true
      notification.custom_data = {"event_request" => true}
      APN.push(notification)
    end
  end
  
  #Etkinlik Kullanıcı İptal
  def send_notification_withdraw(user, event)
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens,
      "data" => { 
        "event_request" => true
      } 
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token)
      notification.content_available = true
      notification.custom_data = {"event_request" => true}
      APN.push(notification)
    end
  end
  
  #Etkinliğe Kullanıcı Ekleme Onayı
  def send_notification_accept_request(user, event)
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens, 
      "data" => {"message" => "#{event.name} adlı aktiviteye katılma isteğiniz onaylandı",
        "title" => "Etkinlik Katılma Onayı"
      }
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => "#{event.name} adlı aktiviteye katılma isteğiniz onaylandı", 
        :badge => 1, :sound => 'default')
      notification.content_available = true
      notification.custom_data = { }
      APN.push(notification)
    end
  end
  
  #Takip Olarak Ekleme İsteği
  def send_notification_follow_user(user)
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens,  
      "data" => {"message" => "#{@user.name} adlı kullanıcı sizi takip etmek istiyor", 
        "follow_request" => true,
        "title" => "Takip İsteği"
      } 
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => "#{@user.name} adlı kullanıcı sizi takip etmek istiyor", 
        :badge => 1, :sound => 'default')
      notification.content_available = true
      notification.custom_data = {"follow_request" => true}
      APN.push(notification)
    end
  end
  
  #Takip İptal
  def send_notification_cancel_follow(user)
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens,  
      "data" => {
        "follow_request" => true
      } 
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token)
      notification.content_available = true
      notification.custom_data = {"follow_request" => true}
      APN.push(notification)
    end
  end
  
  #Takip Olarak Ekleme Onayı
  def send_notification_accept_follow(user)
    gcmTokens = user.sessions.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens, 
      "data" => {"message" => "#{@user.name} adlı kullanıcı takip etme isteğinizi onayladı",
        "title" => "Takip Onayı"
      }
    }
    gcmPushNotification(params)
    
    apnsTokens = user.sessions.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => "#{@user.name} adlı kullanıcı takip etme isteğinizi onayladı", 
        :badge => 1, :sound => 'default')
      notification.content_available = true
      notification.custom_data = { }
      APN.push(notification)
    end
  end
  
  def send_all_notification(title, message)
    gcmTokens = Session.where(:deviceType => Session.deviceTypes[:android]).pluck(:pushToken)
    params = {"registration_ids" => gcmTokens, 
      "data" => {"message" => message,
        "title" => title
      }
    }
    gcmPushNotification(params)
    
    apnsTokens = Session.where(:deviceType => Session.deviceTypes[:ios]).pluck(:pushToken)
    apnsNotifications = []
    apnsTokens.each do |token|
      notification = Houston::Notification.new(:device => token, 
        :alert => message, 
        :sound => 'default')
      notification.content_available = true
      notification.custom_data = { }
      APN.push(notification)
    end
  end
  
end
