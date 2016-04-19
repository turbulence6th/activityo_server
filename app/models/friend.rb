class Friend < ActiveRecord::Base
  
  #Zaten arkadaşsa
  class MatchValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if Friend.exists?(:user_1 => record.user_1, :user_2 => record.user_2) ||
        Friend.exists?(:user_1 => record.user_2, :user_2 => record.user_1)
          record.errors[attribute] << options[:message]
      end
    end
  end
  
  #Kullanıcı kendisini ekleyemiyor
  class OwnValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.user_1 == record.user_2
          record.errors[attribute] << options[:message]
      end
    end
  end
  
  validates :user_1, :match => {
    :message => 'Zaten arkadaşsınız'
  }, :own => {
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
