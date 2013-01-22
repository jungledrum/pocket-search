class User < ActiveRecord::Base
  attr_accessible :id, :pocket_access_token, :username
end
