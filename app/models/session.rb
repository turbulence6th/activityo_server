class Session < ActiveRecord::Base
  
  belongs_to :user
  
  validates :auth_token, :deviceId, :deviceType, :pushToken, :presence => true
  
  enum :deviceType => [:android, :ios]
  
end
