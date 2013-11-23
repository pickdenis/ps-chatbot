require 'faye/websocket'
require 'eventmachine'
require 'net/http'
require 'json'
require './chathandler.rb'

# USAGE: connector.rb user pass room

$data = {}
$login = {
  name: ARGV.shift,
  pass: ARGV.shift
}
$room = ARGV.shift || 'showderp'
EM.run {
  ws = Faye::WebSocket::Client.new('ws://sim.psim.us:8000/showdown/websocket')

  ws.on :open do |event|
    puts "Connection opened"
  end

  ws.on :message do |event|
    message = event.data.split("|")
    #puts event.data
    case message[1]
    when "challstr"
      puts "Attempting to login..."
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
    
      puts "Name updated: #{message[2]}"
      
      ws.send("|/join #{$room}")
      
    when "c", "pm"
      ChatHandler.handle(message, ws)
    end
  
    
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}