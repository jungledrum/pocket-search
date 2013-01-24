require 'active_record'
require 'net/http'
require 'open-uri'
require 'readability'
gem 'mysql2'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "pocket-search_development"
)

class Link < ActiveRecord::Base
  attr_accessible :content, :id, :pocket_id, :status, :title, :type, :url, :crawl_status, :uid
end

@bodys = Hash.new

def crawl(link, links)
  begin
    uri = URI(link.url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
    end
    res = http.get(uri.request_uri, {'User-Agent' => 'Chrome'})
    source = res.body
    @bodys[link.id] = {"content"=>Readability::Document.new(source).content, "crawl_status"=>res.code}
    p links.size
  rescue => detail
    p "-"*10
    p link.url
    p detail
    @bodys[link.id] = {"crawl_status"=>404}
  end
end

links = Link.where("crawl_status is NULL")
p links.size
links = links[0,30]
threads = []

5.times do
  begin
    threads << Thread.new do
      until links.blank?
        link = links.pop
        crawl(link, links)
      end
      Thread.current.exit 
    end
  rescue => detail
    p detail
    # print detail.backtrace.join("\n")
  end
end

p threads
threads.each do |x|
  x.join
end

links.each_with_index do |link, index|
  link.update_attributes("content"=>@bodys[link.id]["content"], "crawl_status"=>@bodys[link.id]["crawl_status"])
end
