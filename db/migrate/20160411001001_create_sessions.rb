class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :user, :index => true
      t.uuid :auth_token, :index => true
      t.uuid :onesignal_token, :index => true
      t.timestamps null: false
    end
  end
end
