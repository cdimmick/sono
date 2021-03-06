class CreateCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :charges do |t|
      t.string :email
      t.string :stripe_id
      t.float :amount
      t.integer :event_id

      t.timestamps
    end
  end
end
