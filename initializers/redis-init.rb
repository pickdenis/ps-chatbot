require 'net/http'
require 'em-redis'

begin
  uri = URI.parse(ENV['REDISTOGO_URL'] || 'redis://localhost:6379')
  
  REDIS = EM::Protocols::Redis.connect(host: uri.host, port: uri.port)
  REDIS.errback do |code|
    $stderr.puts "Error code: #{code}"
  end
rescue => e
  $stderr.puts "Redis error: #{e.message} (Ignore if you're not using redis)"
end

