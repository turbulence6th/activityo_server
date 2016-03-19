class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string :name
      t.string :likeID, :index => true
    end
    
    create_table :likes_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :like, index: true
    end
  end
end
