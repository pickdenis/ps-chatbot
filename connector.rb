# ps-chatbot: a chatbot that responds to commands on Pokemon Showdown chat
# Copyright (C) 2014 pickdenis
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


require 'faye/websocket'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'fileutils'
require 'optparse'


require './app/chatbot.rb'
require './app/chathandler.rb'
require './app/battle.rb'
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
  
  opts.on('-w', '--server SERVER', 'specify server (default is main)') do |v|
    $options[:server] = v
  end
  
  opts.on('-c', '--[no-]console-input', 'console input') do |v|
    $options[:console] = v
  end
  
  opts.on('-s', '--[no-]socket-input', 'socket input') do |v|
    $options[:socket] = v
  end
  
  opts.on('-t', '--no-triggers', 'no triggers') do |v|
    $options[:triggers] = v
  end
  
  opts.on('-l', '--log', 'show everything sent from server') do |v|
    $options[:log] = v
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


require './app/pokedata.rb'

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
      console: $options[:console],
      server: ($options[:server] || nil),
      log: $options[:log],
      triggers: !$options[:triggers])
    
    Signal.trap("INT") do
      bot.exit_gracefully
      Process.exit
    end
    
    if $options[:socket]
      EM.start_server('127.0.0.1', 8081, InputServer)
    end
  end
  


end
