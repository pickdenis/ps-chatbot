


class Chatbot
  include EM::Deferrable
  attr_reader :name, :pass, :connected, :ch, :bh, :id, :config, :dirname, :initializing
  
  PS_URL = 'ws://sim.smogon.com:8000/showdown/websocket'
  
  
  def initialize opts # possible keys: name, pass, group, room, console
    # The bot is initializing - if we try to terminate the program with SIGINT,
    # it won't attempt to exit during this phase because there are things being
    # loaded
    
    @initializing = true
    
    
    @id = opts[:id]
    @name = opts[:name]
    @pass = opts[:pass]
    @avatar = opts[:avatar]
    @log_messages = opts[:log]
    
    @config = opts[:allconfig]
    
    initialize_dir
    run_initializers
    
    @ch = ChatHandler.new(opts[:triggers], self)
    @bh = BattleHandler.new(@ch)
    @connected = false
    
    @do_battles = opts[:dobattles]
    
    
    # load all of the triggers
    if opts[:usetriggers]
      @ch.load_trigger_files
    end
    
    
    @rooms = opts[:room] || opts[:rooms]
    if !@rooms.is_a? Array
      @rooms = [@rooms]
    end

    @room_times = Hash.new
    
    @server = (opts[:server] || PS_URL)
    
    
    if @rooms != 'none'
      connection_checker = EventMachine::PeriodicTimer.new(10) do
        # If not connected, try to reconnect
        if !@connected
          connect
        end
      end
    end
    
    @initializing = false
  end
  
  def initialize_dir
    
    @dirname = "bot-#{@id}"
    
    # initialize all of the directories that we need
    FileUtils.mkdir_p("./#{@dirname}/logs/chat")
    FileUtils.mkdir_p("./#{@dirname}/logs/usage")
    FileUtils.mkdir_p("./#{@dirname}/logs/pms")
    
    FileUtils.touch("./#{@dirname}/accesslist.txt")
  end
  
  def run_initializers
    FileUtils.mkdir_p("./#{@dirname}/initializers")
    files = Dir["./#{@dirname}/initializers/*.rb"] | Dir['./initializers/*.rb']
    
    files.each do |file|
      load(file)
    end
  end
  
  def connect
    ws = Faye::WebSocket::Client.new(@server)
    
    ws.on :open do |event|
      puts "#{@id}: Connection opened"
      @connected = true
    end

    ws.on :message do |event|
      
      messages = event.data.split("\n")
      if messages[0][0] == '>'
        room = messages.shift
      end
      
      messages.each do |rawmessage|
        rawmessage = "#{room}\n#{rawmessage}"
        
        if @log_messages
          puts rawmessage
        end
        
        message = rawmessage.split("|")
        
        
        next if !message[1]
        
        if message[0] =~ />battle-/
          next @bh.handle(message, ws)
        end
        
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
        when 'formats'
          data = message[2..-1].join('|')
          
          # don't bother understanding the next line, it just takes the data PS sends for formats and
          # changes it into a list of formats
          
          $battle_formats = ('|' + data.gsub(/[,#]/, '')).gsub(/\|\d\|[^|]+/, '').split('|').map { |f| CBUtils.condense_name(f) }
        when 'updateuser'
          if CBUtils.condense_name(message[2]) == CBUtils.condense_name(@name)
            puts "#{@id}: Succesfully logged in!"
            
            @rooms.each do |r|
              puts "#{@id}: Joining room #{r}."
              ws.send("|/join #{r}")
            end
            
            start_console(ws) if @console_option
          end
          
          
          
        when 'c', 'pm', 'j', 'n', 'l', 'users'
          @ch.handle(message, ws)
        when 'c:'
          curTime = Integer(message[2])
          if (curTime == nil || curTime > @room_times[message[0][1..-2]])
            @ch.handle(message, ws)
          end
        when 'tournament'
          @ch.handle_tournament(message, ws)
        when 'updatechallenges'
          @bh.handle_challenge(message, ws)
        when ':'
          update_room_time(message[0][1..-2], Integer(message[2]))
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


  # Sets the join time for a room
  def update_room_time room, time
    @room_times[room] = time
  end
              
  def exit_gracefully(&callback)
    @ch.exit_gracefully(&callback)
  end
    
end
