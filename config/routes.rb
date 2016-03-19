Rails.application.routes.draw do
  
  post 'loginFacebook' => 'users#loginFacebook', :defaults => {
   :format => :json
  }
  
  post 'loginGoogle' => 'users#loginGoogle', :defaults => {
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
  
end
