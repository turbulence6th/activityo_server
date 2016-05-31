class May172016 < ActiveRecord::Migration
  def change
    add_column :images, :type, :string, default: "Image"
    Image.all.each do |image|
      image.update_attributes(:type => 'ProfileImage')
    end
  end
end
