class AddIndexForOpenIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :open_id
  end
end
