class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      
      t.references :user_1, :references => :user, :index => true
      t.references :user_2, :references => :user, :index => true
      t.boolean :accepted
      
      t.timestamps null: false
    end
  end
end
