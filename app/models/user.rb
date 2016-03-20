class User < ActiveRecord::Base
  
  enum :gender => [:male, :female]
  
  has_many :events, :dependent => :destroy
  
  has_and_belongs_to_many :likes
  
  has_many :message_send, :class_name => 'Message', :foreign_key => 'from_id', :dependent => :destroy
  has_many :message_receive, :class_name => 'Message', :foreign_key => 'to_id', :dependent => :destroy
  
end
