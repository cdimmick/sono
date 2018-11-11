class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.integer :user_id
      t.integer :admin_id
      t.integer :facility_id
      t.datetime :start_time

      t.timestamps
    end
  end
end
