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
  
  post 'beReference' => 'users#beReference', :defaults => {
     :format => :json
  }
  
  post 'finduser' => 'users#findUser', :defaults => {
     :format => :json
  }
  
  post 'addFriend' => 'users#addFriend', :defaults => {
    :format => :json
  }
  
  post 'acceptRequest' => 'users#acceptRequest', :defaults => {
    :format => :json
  }
  
  post 'deleteRequest' => 'users#deleteRequest', :defaults => {
    :format => :json
  }
  
  post 'cancelRequest' => 'users#cancelRequest', :defaults => {
    :format => :json
  }
  
  post 'deleteFriend' => 'users#deleteFriend', :defaults => {
    :format => :json
  }
  
  post 'joinEvent' => 'events#joinEvent', :defaults => {
    :format => :json
  }
  
  post 'withdrawRequest' => 'events#withdrawRequest', :defaults => {
    :format => :json
  }
  
  post 'friendRequestUsers' => 'users#friendRequestUsers', :defaults => {
    :format => :json
  }
  
  post 'eventRequestUsers' => 'events#eventRequestUsers', :defaults => {
    :format => :json
  }
  
  post 'acceptEventRequest' => 'events#acceptEventRequest', :defaults => {
    :format => :json
  }
  
  post 'rejectEventRequest' => 'events#rejectEventRequest', :defaults => {
    :format => :json
  }
  
  post 'getUserEvents' => 'users#getUserEvents', :defaults => {
    :format => :json
  }
  
  post 'getBasicInfo' => 'users#getBasicInfo', :defaults => {
    :format => :json
  }
  
  get 'callback' => 'users#callback', :defaults => {
    :format => :json
  }
  
end
