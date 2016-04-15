class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.date :birthday
      t.integer :gender  
      t.string :education
      t.string :phone
      t.integer :role
      t.text :description
      
      t.string :facebookID, :index => true
      t.string :googleID, :index => true
      t.string :twitterID, :index => true
      
      t.boolean :notification
      t.boolean :showPhone
      t.boolean :showFriends
      
      t.boolean :deleted  
      
      t.timestamps null: false
    end
  end
end