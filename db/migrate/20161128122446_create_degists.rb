class CreateDegists < ActiveRecord::Migration[5.0]
  def change
    create_table :degists do |t|
      t.belongs_to :user
      t.string :subject
      t.string :class
      t.string :content

      t.timestamps
    end
  end
end
