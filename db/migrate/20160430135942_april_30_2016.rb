class April302016 < ActiveRecord::Migration
  def change
    drop_table :friends
    remove_column :users, :showPhone
    remove_column :users, :showFriends
    
    create_table :follows do |t|
      
      t.references :user_1, :references => :user, :index => true
      t.references :user_2, :references => :user, :index => true
      t.boolean :accepted
      
      t.timestamps null: false
    end
  end
end
