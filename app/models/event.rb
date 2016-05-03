class Event < ActiveRecord::Base
  
  validates :user, :presence => {
    :message => 'Oturum açınız!'
  }
  
  validates :eventType, :presence => {
    :message => 'Aktivite türü seçiniz!'
  }
  
  validates :name, :presence => {
    :message => 'Aktivite adı giriniz!'
  }, :length => {
    :maximum => 150,
    :message => 'Aktivite adı karakter sayısı en fazla 150 olabilir!'
  }
  
  validates :startDate, :presence => {
    :message => 'Başlangıç tarihi giriniz!'
  }
  
  validates :address, :presence => {
    :message => 'Adres giriniz!'
  }, :length => {
    :maximum => 200,
    :message => 'Adres karakter sayısı en fazla 200 olabilir!'
  }
  
  validates :capacity, :numericality => {
    :only_integer => true,
    :greater_than_or_equal_to => 1,
    :allow_nil => true,
    :message => 'Kapasite sadece sayı olabilir!'
  }
  
  validates :description, :length => {
    :maximum => 500
  }
  
  enum :eventType => GlobalConstants::EVENT_TYPES
  
  belongs_to :user
  
  has_one :image, :as => :imageable, :dependent => :destroy
  
  has_many :joins, :dependent => :destroy
  
  has_many :message_receive, :class_name => 'Message',:as => :to, :dependent => :destroy
  
  reverse_geocoded_by :latitude, :longitude
  
end
