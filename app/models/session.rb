class Session < ActiveRecord::Base
  
  belongs_to :user
  
  validates :auth_token, :presence => true
  
  validates :gcmId, :presence => true
  
end
