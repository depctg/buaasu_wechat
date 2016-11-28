class ChangeClassToTypeForDegist < ActiveRecord::Migration[5.0]
  def change
    rename_column :degists, :class, :degist_class
  end
end
