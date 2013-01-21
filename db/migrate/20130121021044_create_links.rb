class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :id
      t.integer :pocket_id
      t.string :url
      t.string :title
      t.text :content
      t.string :type
      t.string :status

      t.timestamps
    end
  end
end
