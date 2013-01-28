class Link < ActiveRecord::Base
  attr_accessible :content, :id, :status, :title, :content_type, :url, :uid
end
