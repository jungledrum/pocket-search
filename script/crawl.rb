require 'active_record'
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
  attr_accessible :content, :id, :pocket_id, :status, :title, :type, :url
end

@bodys = Hash.new

def crawl(link)
  begin
    source = open(link.url).read
    @bodys[link.id] = {"content"=>Readability::Document.new(source).content, "crawl_status"=>200}
  rescue => detail
    @bodys[link.id] = {"crawl_status"=>404}
  end
end

links = Link.where("crawl_status is NULL")
links = links[0,links.size]
threads = []
links.each_with_index do |x, index|
  begin
    threads << Thread.new{crawl(x)}
  rescue => detail
    #print detail.backtrace.join("\n")
  end
  p "#{index} of #{links.size}"
end
threads.each do |x|
  x.join
end

links.each_with_index do |link, index|
  #link.update_attributes("content"=>@bodys[link.id]["content"], "crawl_status"=>404)
  p link.update_attributes("crawl_status"=>"404")
end
