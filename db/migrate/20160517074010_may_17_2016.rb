class May172016 < ActiveRecord::Migration
  def change
    add_column :images, :image_type, :integer, default: "Image"
  end
end
