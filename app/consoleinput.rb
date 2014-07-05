


require 'readline'

class Console
  attr_accessor :ws, :ch
  
  HANDLER_TRIGGERS = [Trigger.new do |t|
    t[:id] = 'console_toff'
    t[:nolog] = true
    
    t.match { |info| 
      info[:where] == 's' &&
      info[:what][0..3] == "toff" &&
      info[:what][5..-1]
    }
    
    t.act { |info| 
      if info[:ch].turn_by_id(info[:result], false)
        info[:respond].call("Turned off trigger: #{info[:result]}")
      else
        info[:respond].call("No such trigger: #{info[:result]}")
      end
    }
  end, Trigger.new do |t|
    t[:id] = 'console_ton'
    t[:nolog] = true
    
    t.match { |info| 
      info[:where] == 's' &&
      info[:what][0..2] == "ton" &&
      info[:what][4..-1]
    }
    
    t.act { |info| 
      if info[:ch].turn_by_id(info[:result], true)
        info[:respond].call("Turned on trigger: #{info[:result]}")
      else
        info[:respond].call("No such trigger: #{info[:result]}")
      end
    }
  end, Trigger.new do |t|
    t[:id] = 'console_customsend'
    t[:nolog] = true
    
    t.match { |info| 
      info[:where] == 's' &&
      info[:what][0..0] == "s" &&
      info[:what][2..-1]
    }
    
    t.act { |info| 
      info[:ws].send(info[:result])
    }
  end, Trigger.new do |t|
    t[:id] = 'console_login'
    t[:nolog] = true
    
    t.match { |info| 
      info[:where] == 's' &&
      info[:what][0..0] == "l" &&
      info[:what][2..-1].split(' ')
    }
    
    t.act { |info| 
      next if info[:result].size != 2
      assertion = CBUtils.login(*info[:result])["assertion"]
      p assertion
      info[:ws].send("|/trn #{info[:result][0]},0,#{assertion}")
    }
  end, Trigger.new do |t|
    t[:id] = 'console_pry'
    t[:nolog] = true
    
    t.match { |info| 
      info[:what] == 'pry' && info[:where] == 's'
    }
    
    t.act { |info| 
      binding.pry
    }
  end, Trigger.new do |t|
    t[:id] = 'console_usagestats'
    t[:nolog] = true
    
    t.match { |info| 
      info[:what] == 'usage' && info[:where] == 's'
    }
    
    t.act { |info| 
      info[:respond].call(info[:ch].print_usage_stats(5))
    }
  end]
  
  def initialize ws, ch
    @ws = ws
    @ch = ch
    
    
  end
  
  def start_loop
    Thread::abort_on_exception = true
  
    
    
    @ci_thread = Thread.new do 
      begin
        
        while input = Readline.readline("console> ", true).strip
          message = [">console\n", 's', input]
          @ch.handle(message, @ws)  # the ws field is left blank because there is no ws
        
        end
      rescue => e
        puts e.message
        puts e.backtrace
      end
      
    end
    
    add_triggers
    
    @ci_thread
  end
  
  def add_triggers
    @ch.triggers.push(*HANDLER_TRIGGERS)
  end
  
  def remove_triggers
    @ch.triggers.delete(*HANDLER_TRIGGERS)
  end
  
  def self.end_thread
    @ci_thread.exit
  end
  
end
