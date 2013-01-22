class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      t.string :pocket_access_token
      t.string :username

      t.timestamps
    end
  end
end
