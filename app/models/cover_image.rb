class CoverImage < Image
  has_attached_file :imagefile, :styles => {:original => '851x315#'},
    :url => "/image/#{Rails.env}#{ENV['RAILS_TEST_NUMBER']}/:hash.jpg",
    :hash_secret => ":id", :default_url => "/default.png"

  validates_attachment :imagefile, :content_type => {
    :content_type => ['image/jpeg', 'image/png'],
    :message => 'Resim olarak jpeg veya png yükleyiniz'
  }, :size => { :in => 0..5.megabytes }

end