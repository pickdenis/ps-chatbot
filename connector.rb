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
require 'yaml'

require './app/chatbot.rb'
require './app/chathandler.rb'
require './app/battle.rb'
require './app/consoleinput.rb'
require './app/socketinput.rb'
require './app/utils.rb'


config = YAML.load(File.open( ARGV[0] || 'config.yml' ))
options = config["options"]

USERNAME = options["name"]
PASSWORD = options["pass"]




require './app/pokedata.rb'

if __FILE__ == $0
  
  
  $0 = "pschatbot"
  
  EM.run do
    
    bot = Chatbot.new(
      name: USERNAME, 
      pass: PASSWORD,
      group: options["tgroup"], 
      room: options["room"], 
      console: options["console"],
      server: (options["server"] || nil),
      log: options["log"],
      triggers: options["triggers"],
      avatar: options["avatar"])
    
    exiting = false
    Signal.trap("INT") do
      next if exiting
      
      exiting = true
      bot.exit_gracefully
      Process.exit
    end
    
    if options[:socket]
      EM.start_server('127.0.0.1', 8081, InputServer)
    end
  end
  


end
