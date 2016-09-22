class CreateCanteenDegists < ActiveRecord::Migration[5.0]
  def change
    create_table :canteen_degists do |t|
      t.string :degist

      t.timestamps
    end
  end
end
