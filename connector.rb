require 'faye/websocket'
require 'eventmachine'
require 'net/http'
require 'json'
require 'fileutils'
require 'optparse'


require './app/chatbot.rb'
require './app/chathandler.rb'
require './app/consoleinput.rb'
require './app/socketinput.rb'
require './app/utils.rb'


$data = {}
$login = {}
$options = {room: 'showderp', tgroup: 'showderp'}


op = OptionParser.new do |opts|
  opts.banner = 'Usage: connector.rb [options]'
  
  opts.on('-n', '--name NAME', 'specify name (required)') do |v|
    $login[:name] = v
  end
  
  opts.on('-p', '--pass PASS', 'specify password (required)') do |v|
    $login[:pass] = v
  end
  
  opts.on('-r', '--room ROOM', 'specify room to join (default is showderp)') do |v|
    $options[:room] = v
  end
  
  opts.on('-c', '--[no-]console-input', 'console input') do |v|
    $options[:console] = v
  end
  
  opts.on('-s', '--[no-]socket-input', 'socket input') do |v|
    $options[:socket] = v
  end
  
  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    Process.exit
  end
end

if ARGV.empty?
  puts op
  Process.exit
end

op.parse!(ARGV)



if __FILE__ == $0
  
  
  #trap("INT") do
  #  puts "\nExiting"
  #  puts "Writing ignore list to file..."
  #  IO.write("./#{$chat.group}/ignored.txt", $chat.ignorelist.join("\n"))
  #  exit
  #end
  
  $0 = "pschatbot"
  
  EM.run do
    bot = Chatbot.new(
      name: $login[:name], 
      pass: $login[:pass], 
      group: $options[:tgroup], 
      room: $options[:room], 
      console: $options[:console])
    
    Signal.trap("INT") do
      bot.exit_gracefully
      Process.exit
    end
    
    if $options[:socket]
      EM.start_server('127.0.0.1', 8081, InputServer)
    end
  end
  


end
