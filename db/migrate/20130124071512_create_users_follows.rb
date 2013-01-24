class CreateUsersFollows < ActiveRecord::Migration
	create_table :users_follows do |t|
		t.integer :user_id, :follow_id
	end
end
