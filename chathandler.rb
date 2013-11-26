module ChatHandler
  
  TRIGGERS = []
  
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
  
  
  def self.handle message, ws
    m_info = make_info(message, ws)
    TRIGGERS.each do |t|
      t[:off] and next
      result = t.is_match?(m_info)
      
      if result
        m_info[:result] = result
        m_info[:respond] = if m_info[:where] == 'c' || m_info[:where] == 's'
          proc { |mtext| m_info[:ws].send("#{m_info[:room]}|#{mtext}") }
        elsif m_info[:where] == 'pm'
          proc { |mtext| m_info[:ws].send("|/pm #{m_info[:who]},#{mtext}") } 
        end 
        t.do_act(m_info)
      end
      
    end
  end
  
  def self.turn_by_id id, on
    TRIGGERS.each do |t|
      if t[:id] == id
        t[:off] = !on
        return true
      end
    end
    
    false
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



# require all trigger files here

require './statcalc/statcalc_trigger.rb'
require './pokemon-related/randbats_trigger.rb'
require './fsymbols/fsymbols_trigger.rb'
require './bread/bread_trigger.rb'