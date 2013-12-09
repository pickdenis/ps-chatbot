require 'faye/websocket'
require 'eventmachine'
require 'net/http'
require 'json'
require 'fileutils'
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
  
  
  
  trap("INT") do
    puts "\nExiting"
    puts "Writing ignore list to file..."
    IO.write("./#{$chat.group}/ignored.txt", $chat.ignorelist.join("\n"))
    exit
  end
  
  EM.run {
    ws = Faye::WebSocket::Client.new('ws://sim.psim.us:8000/showdown/websocket')

    ws.on :open do |event|
      puts "Connection opened"
    end

    ws.on :message do |event|
      message = event.data.split("|")
      case message[1]
      when "challstr"
        puts "Attempting to login..."
        $data[:challenge] = message[3]
        $data[:challengekeyid] = message[2]
        $data[:response] = CBUtils.login "act" => "login",
          "name" => $login[:name],
          "pass" => $login[:pass],
          "challengekeyid" => $data[:challengekeyid].to_i,
          "challenge" => $data[:challenge]
        assertion = $data[:response]["assertion"]
        
        if assertion.nil? 
          raise "Could not login"
        end      
        
        ws.send("|/trn #{$login[:name]},0,#{assertion}")
        
      when "updateuser"
        if message[2] == $login[:name]
          puts 'succesfully logged in!'
          puts 'started console'
          $ci_thread = ConsoleInput.start_loop(ws)
        end
        ws.send("|/join #{$room}")
        
      when "c", "pm"
        $chat.handle(message, ws)
      end
    
      
    end

    ws.on :close do |event|
      puts "connection closed. code=#{event.code}, reason=#{event.reason}"
      ws = nil
    end
  }
  


end
