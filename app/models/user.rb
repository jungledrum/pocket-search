class User < ActiveRecord::Base
  attr_accessible :id, :pocket_access_token, :username
  has_many :items
  has_and_belongs_to_many :follows, :join_table => "users_follows", :class_name => "User",
  												:association_foreign_key => "follow_id"
  has_and_belongs_to_many :fans, :join_table => "users_follows", :class_name => "User",
  												:association_foreign_key => "user_id", :foreign_key => "follow_id"

  def sync
    parsed_url = URI.parse("https://getpocket.com")
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    res = http.get("/v3/get?state=all&consumer_key=11572-e9f22c44fc2b2cf25f14a560&access_token=#{pocket_access_token}")
    body = JSON.parse(res.body)

    body["list"].each do |k, v|
      pocket_id = v["item_id"]
      url = v["given_url"]
      title = v["given_title"]
      time_added = v["time_added"]
      content_type = get_content_type(url)

      link = Link.where("url = '#{url}'").first
      if link.blank?
        link = Link.create(:url => url, :title => title, :content_type => content_type)
      end

      has_link = false
     	self.items.each do |x|
        if x.link_id == link.id
          has_link = true
        end
      end
      unless has_link
        Item.create(:user_id => self.id, :link_id => link.id, :created_at => Time.at(time_added.to_i))
      end
    end
  end

  	def get_content_type(url)
		if url.match('^.+://[^/]+/?$')
			return "site"
		end
	end
end
