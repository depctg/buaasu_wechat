class AddUsedToCanteenDegist < ActiveRecord::Migration[5.0]
  def change
    add_column :canteen_degists, :is_used, :bool, default: false
  end
end
