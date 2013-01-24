class User < ActiveRecord::Base
  attr_accessible :id, :pocket_access_token, :username
  has_and_belongs_to_many :follows, :join_table => "users_follows", :class_name => "User",
  												:association_foreign_key => "follow_id"
  has_and_belongs_to_many :fans, :join_table => "users_follows", :class_name => "User",
  												:association_foreign_key => "user_id", :foreign_key => "follow_id"

end
