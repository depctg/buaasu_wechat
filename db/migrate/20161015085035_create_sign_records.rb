class CreateSignRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :sign_records do |t|
      t.belongs_to :user, index: true
      t.integer :day
      t.text :days

      t.timestamps
    end
  end
end
