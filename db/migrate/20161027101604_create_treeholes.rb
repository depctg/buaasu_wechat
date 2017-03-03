class CreateTreeholes < ActiveRecord::Migration[5.0]
  def change
    create_table :treeholes do |t|
      t.string :name
      t.integer :count
      t.boolean :is_active

      t.timestamps
    end
  end
end
