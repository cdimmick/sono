class CreateFacilities < ActiveRecord::Migration[5.2]
  def change
    create_table :facilities do |t|
      t.string :name
      t.string :phone

      t.boolean :active, default: true 

      t.timestamps
    end
  end
end
