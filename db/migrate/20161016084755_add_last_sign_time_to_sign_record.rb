class AddLastSignTimeToSignRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :sign_records, :last_sign_time, :datetime
    add_index :sign_records, :last_sign_time
  end
end
