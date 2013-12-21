class Chatbot
  include EM::Deferrable
  attr_accessor :name, :pass, :ch # chathandler
  
  PS_URL = 'ws://sim.psim.us:8000/showdown/websocket'
  
  
  def initialize name, pass, tgroup
    @name = name
    @pass = pass
    
    @ch = ChatHandler.new(tgroup)
    FileUtils.touch("./#{@ch.group}/ignored.txt")
    @ch.load_trigger_files
    @ch.ignorelist = IO.readlines("./#{@ch.group}/ignored.txt").map(&:chomp)
    
    @console = Console.new(nil, @ch)
    
    connect
  end
  
  def connect
    ws = Faye::WebSocket::Client.new(PS_URL)
    
    ws.on :open do |event|
      puts "Connection opened"
    end

    ws.on :message do |event|
      message = event.data.split("|")
      
      case message[1]
      when 'challstr'
        puts "Attempting to login..."
        $data[:challenge] = message[3]
        $data[:challengekeyid] = message[2]
        $data[:response] = CBUtils.login $login[:name], $login[:pass]
        assertion = $data[:response]["assertion"]
        
        if assertion.nil? 
          raise "Could not login"
        end      
        
        ws.send("|/trn #{$login[:name]},0,#{assertion}")
        
      when 'updateuser'
        if message[2] == $login[:name]
          puts 'Succesfully logged in!'
          puts 'Started console'
          @console.ws = ws
          @console.start_loop
        end
        ws.send("|/join #{$options[:room]}")
        
        
      when 'c', 'pm'
        @ch.handle(message, ws)
      end
    
    end

    ws.on :close do |event|
      puts "connection closed. code=#{event.code}, reason=#{event.reason}"
      ws = nil
    end
    
    fix_input_server(ws)
  end
  
  def fix_input_server ws
    v_ch = @ch
    InputServer.send :define_method, :receive_data do |data|
      @data << data
      if @data[-1] == "\n"
        message = ['s', @data.strip]
        
        callback = proc do |mtext|
          send_data "#{mtext}\r\n"
        end
        
        v_ch.handle(message, ws, callback)
        @data = ''
      end
    end
  end
    
end
