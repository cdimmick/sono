class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :street2
      t.string :street3
      t.string :number
      t.string :city
      t.string :state
      t.string :zip
      t.integer :has_address_id
      t.integer :has_address_type
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
