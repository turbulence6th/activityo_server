class Message < ActiveRecord::Base
  
  belongs_to :from, :class_name => 'User'
  belongs_to :to, :polymorphic => true
  
end
