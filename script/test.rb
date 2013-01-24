require 'net/http'

url = URI("http://baidu.com")

http = Net::HTTP.new(url.host, url.port)
if url.scheme == "https"
  http.use_ssl = true
end
res = http.get(url.request_uri, {'User-Agent' => 'Chrome'})
p res.code

