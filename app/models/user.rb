class User < ActiveRecord::Base
  
  enum :gender => [:male, :female]
  
  enum :role => [:admin, :member]
  
  has_many :events, :dependent => :destroy
  
  has_and_belongs_to_many :likes
  
  has_many :message_send, :class_name => 'Message', :foreign_key => 'from_id', :dependent => :destroy
  has_many :message_receive, :class_name => 'Message',:as => :to, :dependent => :destroy
  
  has_many :user_1, :class_name => 'Follow', :foreign_key => 'user_1_id', :dependent => :destroy 
  has_many :user_2, :class_name => 'Follow', :foreign_key => 'user_2_id', :dependent => :destroy
  
  has_many :referenced, :class_name => 'Reference', :foreign_key => 'from_id', :dependent => :destroy 
  has_many :be_referenced, :class_name => 'Reference', :foreign_key => 'to_id', :dependent => :destroy
  
  has_one :image, :class_name => 'ProfileImage', :as => :imageable, :dependent => :destroy
  has_one :cover, :class_name => 'CoverImage', :as => :imageable, :dependent => :destroy
  
  has_many :joins, :dependent => :destroy
  
  has_many :sessions, :dependent => :destroy
  
  public
  def get_image
    if !self.image
      return ProfileImage.new
    end
    return self.image
  end
  
  def get_cover
    if !self.cover
      return CoverImage.new
    end
    return self.cover
  end
  
end
