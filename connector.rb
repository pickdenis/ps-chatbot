


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







require './app/pokedata.rb'

if __FILE__ == $0
  
  cfg_file = ARGV[0]
  
  if cfg_file
    puts "Using config file: #{cfg_file}."
  else
    puts "No config file specified, attempting to use 'config.yml'"
    cfg_file = 'config.yml'
  end

  if File.exist?(cfg_file)
    configs = YAML.load(File.open(cfg_file))["bots"]
  else
    raise "config file specified #{cfg_file} does not exist!"
  end
  
  $0 = 'pschatbot'
  
  EM.run do
    bots = []
    configs.each do |options|
      bot = Chatbot.new(
        id: options['id'],
        name: options['name'], 
        pass: options['pass'],
        room: options['room'], # compatibility
        rooms: options['rooms'], 
        console: options['console'],
        server: (options['server'] || nil),
        log: options['log'],
        usetriggers: options['usetriggers'],
        triggers: options['triggers'],
        dobattles: options['dobattles'],
        
        allconfig: options)
      
      bots << bot
      
    end
    
    exiting = false
    exitblk = proc do |&callback|
      
      next if exiting || bots.any?(&:initializing)
      
      exiting = true
      
      bots.each do |bot|
        bot.exit_gracefully(&callback)
      end
      
    end
    
    at_exit &exitblk
    Signal.trap("INT") { exitblk.call { Process.exit(0) } } 
    
  end
  


end
