Rails.application.routes.draw do
  
  post 'loginFacebook' => 'users#loginFacebook', :defaults => {
   :format => :json
  }
  
  post 'loginGoogle' => 'users#loginGoogle', :defaults => {
   :format => :json
  }
  
  post 'logout' => 'users#logout', :defaults => {
   :format => :json
  }
  
  post 'send_message' => 'users#send_message', :defaults => {
   :format => :json
  }
  
  post 'getmessages' => 'users#getmessages', :defaults => {
   :format => :json
  }
  
  post 'showMessage' => 'users#showMessage', :defaults => {
   :format => :json
  }
  
  post 'getEvents' => 'events#getEvents', :defaults => {
   :format => :json
  }
  
  post 'createEvent' => 'events#createEvent', :defaults => {
   :format => :json
  }
  
  post 'showEvent' => 'events#showEvent', :defaults => {
   :format => :json
  }
  
  post 'getUserInfo' => 'users#getUserInfo', :defaults => {
    :format => :json
  }
  
  post 'OtherUserInfo'  => 'users#OtherUserInfo', :defaults => {
     :format => :json
  }
  
  post 'sendComment' => 'users#SendComment', :defaults => {
     :format => :json
  }
  
  post 'finduser' => 'users#findUser', :defaults => {
     :format => :json
  }
  
  post 'addFriend' => 'users#addFriend', :defaults => {
    :format => :json
  }
  
end
