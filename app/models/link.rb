class Link < ActiveRecord::Base
  attr_accessible :content, :id, :pocket_id, :status, :title, :content_type, :url, :uid
end
