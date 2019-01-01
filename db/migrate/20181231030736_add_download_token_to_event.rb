class AddDownloadTokenToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :download_token, :string
  end
end
