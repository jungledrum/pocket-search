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
    @bodys[link.id] = Readability::Document.new(source).content
  rescue => detail
    p "#{link.url} error!!!"
  end
end

links = Link.all
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
  link.update_attribute("content", @bodys[link.id])
end
