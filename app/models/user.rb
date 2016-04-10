class User < ActiveRecord::Base
  
  enum :gender => [:male, :female]
  
  has_many :events, :dependent => :destroy
  
  has_and_belongs_to_many :likes
  
  has_many :message_send, :class_name => 'Message', :foreign_key => 'from_id', :dependent => :destroy
  has_many :message_receive, :class_name => 'Message', :foreign_key => 'to_id', :dependent => :destroy
  
  has_many :user_1, :class_name => 'Friend', :foreign_key => 'user_1_id', :dependent => :destroy 
  has_many :user_2, :class_name => 'Friend', :foreign_key => 'user_2_id', :dependent => :destroy
  
  has_one :image, :as => :imageable, :dependent => :destroy
  
  has_many :joins, :dependent => :destroy
  
  public
  def friends
    user1 = User.select('users.*')
      .from('users, friends')
      .where('friends.user_1_id=? AND friends.user_2_id=users.id AND friends.accepted=TRUE', self.id)
    user2 = User.select('users.*')
      .from('users, friends')
      .where('friends.user_2_id=? AND friends.user_1_id=users.id AND friends.accepted=TRUE', self.id)
    user1.union(user2)
  end
  
  def get_image
    if !self.image
      return Image.new
    end
    return self.image
  end
  
end
