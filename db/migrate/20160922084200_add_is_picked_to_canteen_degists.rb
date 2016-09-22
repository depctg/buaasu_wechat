class AddIsPickedToCanteenDegists < ActiveRecord::Migration[5.0]
  def change
    add_column :canteen_degists, :is_picked, :bool
  end
end
