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

def crawl(link)
  begin
    uri = URI(link.url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
    end
    http.read_timeout = 3
    http.open_timeout = 3
    res = http.get(uri.request_uri, {'User-Agent' => 'Chrome'})
    source = res.body
    @bodys[link.id] = {"content"=>Readability::Document.new(source).content, "crawl_status"=>res.code}
    # @bodys[link.id] = {"content"=>source, "crawl_status"=>res.code}
  rescue => detail
    p detail
    @bodys[link.id] = {"crawl_status"=>1000}
  end
  # l = Link.find(link.id)
  # l.update_attributes("content"=>@bodys[link.id]["content"], "crawl_status"=>@bodys[link.id]["crawl_status"])
end

links = Link.where("crawl_status is NULL").order("id DESC")
links = links[0,links.size]
p links.size
threads = []

links_size = links.size
thread_num = 20
start_time = Time.now
thread_num.times do |index|
  begin
    threads << Thread.new do
      until links.blank?
        link = links.pop
        t1 = Time.now
        crawl(link)
        t2 = Time.now
        puts "T#{index}\t#{links.size}\t#{t2-t1}\t#{link.title[0,20]}\n"
      end
      p "Thread #{index} exit."
      Thread.current.exit 
    end
  rescue => detail
    p detail
    # print detail.backtrace.join("\n")
  end
end

threads.each do |x|
  x.join
end

end_time = Time.now
p "consume_time:#{end_time - start_time}, worker:#{thread_num}, links_size:#{links_size}"

p "=======END========="
@bodys.each do |k, v|
  link = Link.find(k)
  link.update_attributes("content"=>v["content"], "crawl_status"=>v["crawl_status"])
end
