class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :imageable, :polymorphic => true, :index => true
      t.attachment :imagefile
    end
  end
end
