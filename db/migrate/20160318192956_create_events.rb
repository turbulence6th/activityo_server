class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :user
      
      t.integer :eventType
      t.string :name
      t.datetime :startDate
      t.string :address
      t.integer :capacity
      t.text :description
      
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
  end
end
