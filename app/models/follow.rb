class Follow < ActiveRecord::Base
  
  #Kullanıcı kendisini ekleyemiyor
  class OwnValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.user_1 == record.user_2
          record.errors[attribute] << options[:message]
      end
    end
  end
  
  validates :user_1, :own => {
    :message => 'Kendinizi arkadaş olarak ekleyemezsiniz'
  }, :presence => {
    :message => 'User_1 eksik!'
  }, :on => :create
  
  validates :user_2, :presence => {
    :message => 'User_2 eksik!'
  }
  
  belongs_to :user_1, :class_name => 'User'
  
  belongs_to :user_2, :class_name => 'User'
  
end
