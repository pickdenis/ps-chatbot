


require 'logger'
require 'json'
require 'fileutils'

class ChatHandler
  attr_accessor :triggers, :ignorelist, :group, :usagelogger, :chatlogger
  attr_reader :id, :dirname, :name, :pass, :config
  
  def initialize triggers, chatbot
    # mostly convenience
    @id = chatbot.id
    @name = chatbot.name
    @pass = chatbot.pass
    @config = chatbot.config
    @dirname = chatbot.dirname
    
    @trigger_files = triggers
    
    @triggers = []
    @trigger_paths = {}
    
    @ignorelist = []

    initialize_ignore_list
    
    # useless and redundant feature
    #initialize_usage_stats
    
    initialize_loggers
    
    initialize_message_queue
  end
  
  def initialize_ignore_list
    
    @ignore_path = "./#{@dirname}/ignored.txt"
    FileUtils.touch(@ignore_path)
    @ignorelist = IO.readlines(@ignore_path).map(&:chomp)
  end
  
  def initialize_loggers
    @usagelogger = Logger.new("./#{@dirname}/logs/usage/usage.log", 'monthly')
    @pmlogger = Logger.new("./#{@dirname}/logs/pms/pms.log", 'monthly')
    @pmlogger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}: #{msg}\n"
    end
    @chatloggers = {} # add one for every new room

  end
  
  def initialize_usage_stats
    @usage_stats = {"c" => {}, "s" => {}, "pm" => {}}
    
    @usage_path = "./#{@dirname}/logs/usagestats.txt"
    
    FileUtils.touch(@usage_path)
    
    if File.zero?(@usage_path)
      File.open(@usage_path, "w") do |f|
        f.puts(JSON.dump(@usage_stats))
      end
    else
      File.open(@usage_path, "r") do |f|
        @usage_stats = JSON.parse(f.gets)
      end
    end
    
    
  end
  
  def print_usage_stats howmany
    "deprecated"
    #relevant_stats = @usage_stats['c'].to_a
    # 
    #buf =  "Top #{howmany} (ab)users: \n"
    # 
    #relevant_stats.sort! {|(x, y)| y.length }
    # 
    #buf << '  ' << relevant_stats.take(howmany).map { |(x, y)| [x, y.size] }.join("\t") << "\n"
    #buf
  end
  
  def initialize_message_queue
    @message_queue = EM::Queue.new
    
    timer = EM::PeriodicTimer.new(0.1) do
      @message_queue.pop do |msg|
        ws, msg = msg
        ws.send(msg)
      end
    end
  end
  
  def queue_message ws, msg
    throw "Message queue not initialized" if !@message_queue
    @message_queue.push([ws, msg])
  end
  
  def load_trigger_files
    
    files = @trigger_files.map { |f| Dir[f] }.flatten
    
    if files
      files.each do |f|
        load_trigger("#{f}")
      end
    end
    
  end
  
  def load_trigger(file)
    puts "#{@id}: loading:  #{file}"
    
    begin
      trigger = load_trigger_code(File.read(file), file)
    rescue Exception => e
      puts e.message
      return false
    end
    
    return false if !trigger
    
    if trigger[:id]
      @trigger_paths[trigger[:id]] = file
    end
  end
  
  def load_trigger_code(code, file='(no file given)')
    
    ch = self # This is so that 'ch' can be accessed within the trigger
    
    begin
      trigger = eval(code, binding, file)
    rescue Exception => e
      puts e.message
      return false
    end
    
    return unless trigger.is_a? Trigger
    
    trigger[:ch] = self
    trigger[:login_name] = @name
    
    trigger.init
    
    @triggers << trigger
    
    trigger
    
  end
  
  def reload_trigger(id)
    trigger = get_by_id(id)
    return false if !trigger
    trigger.call_exit
    @triggers.delete(trigger)
    load_trigger(@trigger_paths[id])
    true
  end
  
  def make_info message, ws
    info = {where: message[1], ws: ws, all: message, ch: self, id: @id, what: ''}
    info.merge!(
      case info[:where].downcase
      when 'c:'
        {
          where: 'c',
          room: message[0][1..-2],
          who: message[3][1..-1],
          fullwho: message[3],
          what: message[4] || '',
        }

      when 'c'
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          fullwho: message[2],
          what: message[3],
        }

      when 'j', 'l'
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          fullwho: message[2],
          what: ''
        }
      when 'n'
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          fullwho: message[2],
          oldname: message[3],
          what: ''
          
        }
      when 'users'
        {
          room: message[0][1..-2],
          who: '',
          what: message[2]
        }
      when 'pm'
        {
          what: message[4],
          to: message[3][1..-1],
          who: message[2][1..-1],
          fullwho: message[2]
        }
      when 's'
        {
          room: message[0],
          who: @name,
          what: message[2],
        }
      end)
    
    info[:rawroom] = info[:room]
    info[:room] && info[:room] = CBUtils.condense_name(info[:room])
    info
  end
  
  
  def handle message, ws, callback = nil
    
    m_info = self.make_info(message, ws)
    
    @ignorelist.map(&:downcase).index(m_info[:who].downcase) and return
    
    @triggers.sort_by { |t| t[:priority] }.reverse_each do |t|
      t[:off] and next
      result = t.is_match?(m_info)
      
      if result
        m_info[:result] = result
        
        o_callback = 
          case m_info[:where].downcase
          when 'c', 'j', 'n', 'l'
            proc do |mtext| queue_message(m_info[:ws], "#{m_info[:room]}|#{mtext}") end
          when 'pm'
            proc do |mtext| queue_message(m_info[:ws], "|/pm #{m_info[:who]},#{mtext}") end
          else
            proc do |mtext| $stderr.puts(mtext) end
          end
        
        m_info[:respond] = (callback || o_callback)
        
        
        
        # log the action
        if t[:id] && !t[:nolog] # only log triggers with IDs
          @usagelogger.info("#{m_info[:who]} tripped trigger id:#{t[:id]}")
          
          # Add to the stats
          #usage_stats_here = @usage_stats[m_info[:where]]
          #
          #usage_stats_here[m_info[:who]] ||= []
          #usage_stats_here[m_info[:who]] << t[:id]
        end
        
        begin
          
          t.do_act(m_info)
        
        rescue Exception => e
          puts "Crashed in trigger #{t}"
          puts e.message
          puts e.backtrace
          STDOUT.flush
          
          m_info[:respond].call("Crashed in trigger #{t}; temporarily turning off.")
          t[:off] = true
        end   
        
      end
      
    end
    
    
    # Log any chat messages
    if m_info[:where] == 'c'
      logger = @chatloggers[m_info[:room]]
      if !logger
        logger = @chatloggers[m_info[:room]] = Logger.new("./#{@dirname}/logs/chat/#{m_info[:room]}.log", 'monthly')
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime}: #{msg}\n"
        end
      end
      
      logger.info("#{m_info[:who]}: #{m_info[:what]}")
    end
    
    if m_info[:where] == 'pm'
      @pmlogger.info("#{m_info[:who]}: #{m_info[:what]}")
      
    end
  end
  
  def handle_tournament message, ws
    
    # Code adapted from
    # https://github.com/raymoo/ps-chatbot-llewd/commit/914f952a7371a6cfbcdf75fa87e349f0539a616a
    
    room = message[0][1..-2]
    action = message[2]
    
    if action == 'create' && message[3] == 'challengecup1vs1'
      ws.send("#{room}|/tour join")
    end
    
    if action == 'update'
      info = JSON.parse(message[3], max_nesting: 100)
      
      if info['challenged']
        ws.send("#{room}|/tour acceptchallenge")
      end
      
      if info["challenges"] && info["challenges"].length != 0
        ws.send("#{room}|/tour challenge #{info["challenges"][0]}")
      end
    end
      
  end
  
  def get_by_id(id)
    @triggers.find { |t| t[:id] == id }
  end
  
  def turn_by_id id, on
    t = get_by_id(id)
    return if !t
    t[:off] = !on
  end
  
  # convenience methods
  
  def turn_off id
    turn_by_id(id, false)
  end
  
  def turn_on id
    turn_by_id(id, true)
  end
  
  
  
  
  
  
  def exit_gracefully(&callback)
    # Write the usage stats to the file
    
    #File.open(@usage_path, 'w') do |f|
    #  f.puts(JSON.dump(@usage_stats))
    #end
    
    # Write ignore list to the file
    
    IO.write(@ignore_path, @ignorelist.join("\n"))
    
    puts "#{@id}: Calling triggers' exit sequences..."
    
    left = @triggers.count(&:exit_takes_callback?)
    @triggers.each do |trigger|
      
      trigger.call_exit do |can_exit|
        if can_exit
          left -= 1
        end
        
        if left <= 0
          puts "#{@id}: Done with exit sequence"
          callback.call if block_given?
        end
      end
    end
    
    
    
  end
  
  def << trigger
    @triggers.push(trigger)
    self
  end
  
  
  
  def has_access(user)
    IO.readlines("./#{@dirname}/accesslist.txt").map(&:strip).index(CBUtils.condense_name(user))
  end
  

end

class Trigger
  
  def initialize &blk
    @vars = {}
    set(:priority, 0)
    yield self
  end
  
  def match &blk
    @match = blk
  end
  
  def act &blk
    @action = blk
  end
  
  # Optional trigger field
  # t.exit { what to do when chatbot exits }
  def exit &blk
    @exit = blk
  end
  
  def exit_takes_callback?
    return false if !@exit
    @exit.arity == 1
  end
  
  def call_exit &blk
    return if !@exit
    @exit.call(blk)
  end
  
  # Optional trigger field
  # t.init { what to do when trigger is initialized }
  def init &blk
    if block_given?
      @init = blk
    else
      if @init
        @init.call
      end
    end
  end
  
  def is_match? m_info
    @match.call(m_info)
  end
  
  def do_act m_info
    @action.call(m_info)
  end
  
  def get var
    @vars[var]
  end
  
  def set var, to
    @vars[var] = to
  end
  
  def to_s
    get(:id) || '<no id>'
  end
  
  
  alias_method :[], :get
  alias_method :[]=, :set
end

