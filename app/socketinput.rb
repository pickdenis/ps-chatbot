


require 'eventmachine'


module InputServer
  
  
  def post_init
    puts "Recieved a connection to the socket"
    @data = ""
  end

  def receive_data data
    puts "old method"
    # this should be changed
  end

  def unbind
    puts "Client disconnected"
  end
end
