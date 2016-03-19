class Event < ActiveRecord::Base
  
  enum :eventType => GlobalConstants::EVENT_TYPES
  
  belongs_to :user
  
  geocoded_by :address
  after_validation :geocode
  
end
