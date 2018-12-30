class AddTimezoneToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :timezone, :string
  end
end
