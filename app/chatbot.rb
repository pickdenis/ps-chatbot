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
  attr_reader :name, :pass, :connected, :ch, :bh, :id
  
  PS_URL = 'ws://sim.smogon.com:8000/showdown/websocket'
  
  
  def initialize opts # possible keys: name, pass, group, room, console
    @id = opts[:id]
    @name = opts[:name]
    @pass = opts[:pass]
    @log_messages = opts[:log]
    
    @ch = ChatHandler.new(opts[:triggers], self)
    @bh = BattleHandler.new(@ch)
    @connected = false
    
   
    @do_battles = opts[:dobattles]
    
    
    # load all of the triggers
    if opts[:usetriggers]
      @ch.load_trigger_files
    end
    
    
    @room = opts[:room]
    
    @server = (opts[:server] || PS_URL)
    
    if @room != 'none'
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
      puts "#{@id}: Connection opened"
      @connected = true
    end

    ws.on :message do |event|
      if @log_messages
        puts event.data
      end
      
      message = event.data.split("|")
      next if !message[1]
      case message[1].downcase
      when 'challstr'
        puts "#{@id}: Attempting to login..."
        data = {}
        CBUtils.login(@name, @pass, message[3], message[2]) do |assertion|
          
          if assertion.nil? 
            raise "#{@id}: Could not login"
          end      
          
          ws.send("|/trn #{@name},0,#{assertion}")
        
        end
        
      when 'updateuser'
        if message[2] == @name
          puts "#{@id}: Succesfully logged in!"
          
          start_console(ws) if @console_option
        end
        ws.send("|/join #{@room}")
        
        
      when 'c', 'pm', 'j', 'n', 'l'
        @ch.handle(message, ws)
      when 'tournament'
        @ch.handle_tournament(message, ws)
      when 'updatechallenges'
        @bh.handle_challenge(message, ws)
      else
        if message[0] =~ />battle-/
          @bh.handle(message, ws)
        end
      end
      
      
    end

    ws.on :close do |event|
      puts "#{@id}: connection closed. code=#{event.code}, reason=#{event.reason}"
      @connected = false
      ws = nil
    end
    
    
    if @do_battles
      @bh.battle_loop('challengecup1vs1', ws)
    end
  end
  
  def exit_gracefully
    @ch.exit_gracefully
  end
    
end
