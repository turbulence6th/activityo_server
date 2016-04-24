class CreateJoins < ActiveRecord::Migration
  def change
    create_table :joins do |t|
      t.references :event, :index => true
      t.references :user, :index => true
      t.boolean :allowed
    end
  end
end
