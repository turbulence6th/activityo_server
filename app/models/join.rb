class Join < ActiveRecord::Base
  
  class CapacityValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless !record.event.capacity || 
        record.event.joins.where(:allowed => true).count < record.event.capacity
          record.errors[attribute] << options[:message]
      end
    end
  end
  
  validates :event, :uniqueness => {
    :scope => :user
  }, :presence => {
    :message => 'Etkinlik Seçiniz!'
  }, :capacity => {
    :message => 'Etkinlik kapasitesi dolmuş!'
  }
  
  validates :user, :presence => {
    :message => 'Oturum açınız'
  }
  
  belongs_to :event
  
  belongs_to :user
  
end