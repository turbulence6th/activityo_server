class April252016 < ActiveRecord::Migration
  def change
    remove_column :sessions, :onesignal_token
    add_column :sessions, :gcmId, :string, :index => true
    rename_table :comments, :references
    add_index :events, :user_id
  end
end
