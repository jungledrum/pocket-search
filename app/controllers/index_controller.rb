require 'net/http'
require 'json'

class IndexController < ApplicationController

  def index
    if session[:uid]
      @user = User.find(session[:uid])

      @items = Hash.new
      last_date = ""
      @user.items.each do |x|
        cur_date = x.created_at.to_s[0,10]
        unless last_date == cur_date
          last_date = cur_date 
          @items[cur_date] = Array.new
        end
        @items[cur_date] << x
      end
    end
  end

  def login
    redirect_uri = "http://localhost:3000/index/callback"

    parsed_url = URI.parse("https://getpocket.com")
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    res = http.post("/v3/oauth/request","consumer_key=11572-e9f22c44fc2b2cf25f14a560&redirect_uri=#{redirect_uri}")
    request_token = res.body[5,res.body.size]
    cookies[:request_token] = request_token
    redirect_to "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{redirect_uri}"
  end

  def logout
    session[:uid] = nil

    redirect_to :action=>"index"
  end

  def get_access_token
    p "="*50
    p "get_access_token"
    parsed_url = URI.parse("https://getpocket.com")
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    request_token = cookies[:request_token]
    p Time.now.to_f
    res = http.post("/v3/oauth/authorize","consumer_key=11572-e9f22c44fc2b2cf25f14a560&code=#{request_token}")
    p Time.now.to_f
    s = res.body.match('access_token=(.*)&username=(.*)')
    p Time.now.to_f

    p "="*50
    p "get_access_token"

    [s[1], s[2]]
  end

  def callback
    access_token, username = get_access_token
    @user = User.where("pocket_access_token = '#{access_token}'").first
    if @user.blank?
      @user = User.create("pocket_access_token"=>access_token, "username"=>username)
    end
    session[:uid] = @user.id

    redirect_to :action=>"index"
  end


  def sync
    user = User.find(session[:uid])

    parsed_url = URI.parse("https://getpocket.com")
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    res = http.get("/v3/get?state=all&consumer_key=11572-e9f22c44fc2b2cf25f14a560&access_token=#{user.pocket_access_token}")
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
      user.items.each do |x|
        if x.id == link.id
          has_link = true
        end
      end
      unless has_link
        Item.create(:user_id => user.id, :link_id => link.id, :created_at => Time.at(time_added.to_i))
      end
    end

    redirect_to root_path
  end

  def get_content_type(url)
    if url.match('^.+://[^/]+/?$')
      return "site"
    end
  end
end
