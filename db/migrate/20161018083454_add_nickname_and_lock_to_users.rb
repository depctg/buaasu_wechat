class AddNicknameAndLockToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :nickname, :string
    add_column :sign_records, :lock, :boolean
  end
end
