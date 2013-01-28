class CreateUsersLinks < ActiveRecord::Migration
	create_table :users_links do |t|
		t.integer :user_id, :link_id

    t.timestamps
	end
end
