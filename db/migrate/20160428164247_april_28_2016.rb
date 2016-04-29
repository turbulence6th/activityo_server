class April282016 < ActiveRecord::Migration
  def change
    remove_column :sessions, :gcmId
    add_column :sessions, :deviceId, :string, :index => true
    add_column :sessions, :deviceType, :integer, :index => true
    add_column :sessions, :pushToken, :string, :index => true
  end
end
