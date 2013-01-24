require 'net/http'
require 'json'

class IndexController < ApplicationController

  def index
    p "="*100
    p session
    if session[:uid]
      @links = Link.where("uid = #{session[:uid]}")
      @user = User.find(session[:uid])
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

    #links = Link.where("uid = #{user.id}")
    #links.each do |x|
    #  x.destroy 
    #end
    
    body["list"].each do |k, v|
      pocket_id = v["item_id"]
      url = v["given_url"]
      title = v["given_title"]
      content_type = get_content_type(url)

      has_link = Link.where("url = '#{url}' and uid = #{user.id}")
      if has_link.blank?
        Link.create(:pocket_id => pocket_id, :url => url, :title => title, :uid => user.id, :content_type => content_type)
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
