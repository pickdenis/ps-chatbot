require 'net/http'
require 'em-redis'


# This is probably the worst hack you'll ever see in this project
#
# em-redis is no longer maintained so I have to redefine a method inside it even though
# I only want to change a few lines

EM::Protocols::Redis.send :define_method, :unbind do # Oh god, why
  @logger.debug { "Disconnected" }  if @logger
  if @connected || @reconnecting
    EM.add_timer(1) do
      @logger.debug { "Reconnecting to #{@host}:#{@port}" }  if @logger
      reconnect @host, @port
      auth_and_select_db
    end
    @connected = false
    @reconnecting = true
    @deferred_status = nil
  else
    $stderr.puts "Could not connect to Redis (ignore if you're not using Redis)" # This is the changed section
    CBUtils.not_connected
  end
end

module CBUtils
  uri = URI.parse(ENV['REDISTOGO_URL'] || 'redis://localhost:6379')

  REDIS = EM::Protocols::Redis.connect(host: uri.host, port: uri.port)
  REDIS.errback do |code|
    $stderr.puts "Error code: #{code}"
  end
  
  @@connected_to_redis = true
  def self.connected_to_redis?
    @@connected_to_redis
  end
  
  def self.not_connected
    @@connected_to_redis = false
  end
end



