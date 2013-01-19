require 'net/http'
require 'json'

class IndexController < ApplicationController

  def index
    parsed_url = URI.parse("https://getpocket.com")
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    res = http.post("/v3/oauth/request","consumer_key=11572-e9f22c44fc2b2cf25f14a560&redirect_uri=http://localhost/index/callback")
    request_token = res.body[5,res.body.size]
    cookies[:request_token] = request_token
    redirect_to "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=http://localhost/index/callback"

  end

  def callback
    parsed_url = URI.parse("https://getpocket.com")
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true
    request_token = cookies[:request_token]
    res = http.post("/v3/oauth/authorize","consumer_key=11572-e9f22c44fc2b2cf25f14a560&code=#{request_token}")

    res = http.get("/v3/get?count=10&detailType=simple&consumer_key=11572-e9f22c44fc2b2cf25f14a560&access_token=5bc0a17d-c72c-e9c9-113d-1bd194")
    @body = JSON.parse(res.body)

  end
end
