require 'eventmachine'


module InputServer
  
  
  def post_init
    puts "Socket connection"
    @data = ""
  end

  def receive_data data
    # this should be changed
  end

  def unbind
    puts "Socket disconnection"
  end
end