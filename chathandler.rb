module ChatHandler
  
  TRIGGERS = []
  
  def self.make_info message, ws
    info = {
      room: message[0][1..-2],
      where: "c",
      who: message[2][1..-1],
      what: message[3],
      ws: ws
    }
    
    if message[1] == "pm"
      info[:where] = "pm"
      info[:what] = message[4]
      info[:to] = message[3][1..-1]
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
        else 
          proc { |mtext| m_info[:ws].send("|/pm #{m_info[:who]},#{mtext}") } 
        end 
        t.do_act(m_info)
      end
      
    end
  end

end

class Trigger
  
  def initialize &blk
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
end

# pokedex data here:

require './pokedex/load.rb'

# require all trigger files here

require './statcalc_trigger.rb'
require './randbats_trigger.rb'
