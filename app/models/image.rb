class Image < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  
  has_attached_file :imagefile, :styles => { :original => '200x200#' },
    :url => "/image/#{Rails.env}#{ENV['RAILS_TEST_NUMBER']}/:hash.:extension", 
    :hash_secret => ":id", :default_url => "/resources/images/default.png"

  validates_attachment :imagefile, :content_type => {
    :content_type => ['image/jpeg', 'image/png'],
    :message => 'Resim olarak jpeg veya png yükleyiniz'
  }, :size => { :in => 0..2.megabytes }

  validates :imagefile, :attachment_presence => true
end
