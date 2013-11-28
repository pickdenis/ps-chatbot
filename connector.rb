require 'faye/websocket'
require 'eventmachine'
require 'net/http'
require 'json'
require './chathandler.rb'
require './consoleinput.rb'
require './logger.rb'

# USAGE: connector.rb user pass room

$data = {}
$login = {
  name: ARGV.shift,
  pass: ARGV.shift
}
$room = ARGV.shift || 'showderp'

trap("INT") do
  $logger.info 'Gracefully exiting...'
  exit
end


if __FILE__ == $0

  
  EM.run {
    ws = Faye::WebSocket::Client.new('ws://sim.psim.us:8000/showdown/websocket')

    ws.on :open do |event|
      $logger.info "Connection opened"
    end

    ws.on :message do |event|
      message = event.data.split("|")
      #puts event.data
      case message[1]
      when "challstr"
        $logger.info "Attempting to login..."
        $data[:challenge] = message[3]
        $data[:challengekeyid] = message[2]
        uri = URI.parse("https://play.pokemonshowdown.com/action.php")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data "act" => "login",
          "name" => $login[:name],
          "pass" => $login[:pass],
          "challengekeyid" => $data[:challengekeyid].to_i,
          "challenge" => $data[:challenge]
      
        $data[:response] = JSON.parse(http.request(request).body[1..-1]) # PS returns a ']' before the json
        
        assertion = $data[:response]["assertion"]
        
        if assertion.nil? 
          raise "Could not login"
        end      
        
        ws.send("|/trn #{$login[:name]},0,#{assertion}")
        
      when "updateuser"
        if message[2] == $login[:name]
          $logger.info 'succesfully logged in!'
          $logger.info, 'started console'
          ci_thread = ConsoleInput.start_loop(ws)
        end
        ws.send("|/join #{$room}")
        
      when "c", "pm"
        $chat.handle(message, ws)
      end
    
      
    end

    ws.on :close do |event|
      $logger.info "connection closed. code=#{event.code}, reason=#{event.reason}"
      ws = nil
    end
  }
  
  

end
