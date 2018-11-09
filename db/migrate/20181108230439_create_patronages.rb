class CreatePatronages < ActiveRecord::Migration[5.2]
  def change
    create_table :patronages do |t|
      t.integer :user_id
      t.integer :facility_id

      t.timestamps
    end
  end
end
