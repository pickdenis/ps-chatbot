require 'logger'

class ChatHandler
  attr_accessor :triggers, :ignorelist, :group, :usagelogger
  
  def initialize group
    @triggers = []
    @ignorelist = []
    @group = group
    
    initialize_loggers
    
  end
  
  def initialize_loggers
    
    @usagelogger = Logger.new("./#{@group}/logs/usage.log", 'daily')
  end
  
  def load_trigger_files
    
    files = IO.readlines("./#{@group}/triggers").map(&:chomp)
    
    if files
      files.each do |f|
        puts "loading:  ./#{@group}/#{f}"
        @triggers << eval(File.read("./#{@group}/#{f}"))
      end
    end
    
  end
  
  def self.make_info message, ws
    info = {where: message[1], ws: ws}
    
    info.merge!(if info[:where] == 'c'
      {
        room: message[0][1..-2],
        who: message[2][1..-1],
        what: message[3],
      }
    elsif info[:where] == 'pm'
      {
        what: message[4],
        to: message[3][1..-1],
        who: message[2][1..-1],
      }
    elsif info[:where] = 's'
      {
        room: $room,
        who: $login[:name],
        what: message[1],
      }
    end)
    
    info
  end
  
  
  def handle message, ws, callback = nil
    m_info = self.class.make_info(message, ws)
    @ignorelist.map(&:downcase).index(m_info[:who].downcase) and return
    
    @triggers.each do |t|
      t[:off] and next
      result = t.is_match?(m_info)
      
      if result
        m_info[:result] = result
        
        m_info[:respond] = (callback || if m_info[:where] == 'c'
          proc do |mtext| m_info[:ws].send("#{m_info[:room]}|#{mtext}") end
        elsif m_info[:where] == 's'
          proc do |mtext| puts mtext end
        elsif m_info[:where] == 'pm'
          proc do |mtext| m_info[:ws].send("|/pm #{m_info[:who]},#{mtext}") end
        end)
        
        # log the action
        if t[:id] && !t[:nolog] # only log triggers with IDs
          @usagelogger.info("#{m_info[:who]} tripped trigger id:#{t[:id]}")
        end
        
        t.do_act(m_info)
        
      end
      
    end
  end
  
  def turn_by_id id, on
    @triggers.each do |t|
      if t[:id] == id
        t[:off] = !on
        return true
      end
    end
    
    false
  end
  
  def << trigger
    @triggers.push(trigger)
    self
  end

end

class Trigger
  
  def initialize &blk
    @vars = {}
    yield self
  end
  
  def match &blk
    @match = blk
  end
  
  def act &blk
    @action = blk
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
  
  alias_method :[], :get
  alias_method :[]=, :set
end

