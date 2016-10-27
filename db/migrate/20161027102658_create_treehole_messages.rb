class CreateTreeholeMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :treehole_messages do |t|
      t.belongs_to :user
      t.belongs_to :treehole
      t.string :content, limit: 255

      t.timestamps
    end
  end
end
