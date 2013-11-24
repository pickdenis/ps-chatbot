module ChatHandler
  
  TRIGGERS = []
  
  def self.make_info message, ws
    info = {where: message[1]}
    
    info = if info[:where] == 'c'
      {
        room: message[0][1..-2],
        where: message[1],
        who: message[2][1..-1],
        what: message[3],
        ws: ws
      }
    elsif info[:where] == 'pm'
      {
        where: message[1],
        what: message[4],
        to: message[3][1..-1],
        ws: ws
      }
    elsif info[:where] = 's'
      {
        room: nil,
        who: $login[:name],
        what: message[1],
        where: info[:where]
      }
    end
    
    info
  end
  
  
  def self.handle message, ws
    m_info = make_info(message, ws)
    TRIGGERS.each do |t|
      result = t.is_match?(m_info)
      
      if result
        m_info[:result] = result
        m_info[:respond] = if m_info[:where] == 'c'
          proc { |mtext| m_info[:ws].send("#{m_info[:room]}|#{mtext}") }
        elsif m_info[:where] == 'pm'
          proc { |mtext| m_info[:ws].send("|/pm #{m_info[:who]},#{mtext}") } 
        end 
        t.do_act(m_info)
      end
      
    end
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


# load helper files

require './pokemon-related/load.rb'
require './fsymbols/textgen.rb'

# require all trigger files here

require './statcalc/statcalc_trigger.rb'
require './pokemon-related/randbats_trigger.rb'
require './fsymbols/fsymbols_trigger.rb'