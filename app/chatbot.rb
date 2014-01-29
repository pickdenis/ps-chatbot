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


class Chatbot
  include EM::Deferrable
  attr_accessor :name, :pass, :connected, :ch # chathandler
  
  PS_URL = 'ws://sim.smogon.com:8000/showdown/websocket'
  
  
  def initialize opts # possible keys: name, pass, group, room, console
    @name = opts[:name]
    @pass = opts[:pass]
    
    @ch = ChatHandler.new(opts[:group])
    @connected = false
    
   
    
    
    
    # load all of the triggers
    
    @ch.load_trigger_files
    
    # initialize console if requested
    
    @console = Console.new(nil, @ch)
    @console_option = opts[:console]
    
    if !@console_option
      @console.add_triggers
    end
    
    @room = opts[:room]
    
    @server = (opts[:server] || PS_URL)
    
    if @room == 'none'
      fix_input_server(nil)
      start_console(nil) if @console_option
    else
      connection_checker = EventMachine::PeriodicTimer.new(10) do
        # If not connected, try to reconnect
        if !@connected
          connect
        end
      end
    end
  end
  
  def connect
    ws = Faye::WebSocket::Client.new(@server)
    
    ws.on :open do |event|
      puts "Connection opened"
      @connected = true
    end

    ws.on :message do |event|
      message = event.data.split("|")
      next if !message[1]
      case message[1].downcase
      when 'challstr'
        puts "Attempting to login..."
        $data[:challenge] = message[3]
        $data[:challengekeyid] = message[2]
        $data[:response] = CBUtils.login @name, @pass
        
        assertion = $data[:response]["assertion"]
        
        if assertion.nil? 
          raise "Could not login"
        end      
        
        ws.send("|/trn #{$login[:name]},0,#{assertion}")
        
      when 'updateuser'
        if message[2] == $login[:name]
          puts 'Succesfully logged in!'
          
          start_console(ws) if @console_option
        end
        ws.send("|/join #{$options[:room]}")
        
        
      when 'c', 'pm', 'j', 'n', 'l'
        @ch.handle(message, ws)
        
      end
    end

    ws.on :close do |event|
      puts "connection closed. code=#{event.code}, reason=#{event.reason}"
      @connected = false
      ws = nil
    end
    
    fix_input_server(ws)
  end
  
  def start_console ws
    puts 'Started console'
    @console.ws = ws
    @console.start_loop
  end
  
  def fix_input_server ws
    v_ch = @ch
    InputServer.send :define_method, :receive_data do |data|
      @data ||= ''
      
      if data == "\b"
        @data = @data[0..-2]
      else
        @data << data
      end
      
      if @data[-1] == "\n"
        message = [">socket\n", 's', @data.strip]
        
        callback = proc do |mtext|
          send_data "#{mtext}\r\n"
        end
        
        v_ch.handle(message, ws, callback)
        @data = ''
      end
    end
  end
  
  def exit_gracefully
    @ch.exit_gracefully
  end
    
end
