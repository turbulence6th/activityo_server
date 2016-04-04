class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      
      t.references :from, :references => :user, :index => true
      t.references :to, :references => :user, :index => true
      t.string :text
      t.timestamps null: false
    end
  end
end
