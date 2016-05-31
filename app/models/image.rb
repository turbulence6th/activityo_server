class Image < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  validates :imagefile, :attachment_presence => true
end



