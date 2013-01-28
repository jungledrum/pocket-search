class Item < ActiveRecord::Base
  attr_accessible :user_id, :link_id, :created_at, :updated_at
  belongs_to :link
  belongs_to :user
end
