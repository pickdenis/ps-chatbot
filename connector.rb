require 'faye/websocket'
require 'eventmachine'
require 'net/http'
require 'json'
require 'fileutils'
require './app/chatbot.rb'
require './app/chathandler.rb'
require './app/consoleinput.rb'
require './app/utils.rb'

# USAGE: connector.rb user pass room

$data = {}
$login = {
  name: ARGV.shift,
  pass: ARGV.shift
}
$room = ARGV.shift || 'showderp'


if __FILE__ == $0
  
  
  #trap("INT") do
  #  puts "\nExiting"
  #  puts "Writing ignore list to file..."
  #  IO.write("./#{$chat.group}/ignored.txt", $chat.ignorelist.join("\n"))
  #  exit
  #end
  
  EM.run {
    bot = Chatbot.new($login[:name], $login[:pass], 'showderp')
  }
  


end
