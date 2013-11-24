def log *argv
  print "#{File.basename(__FILE__)}: "
  puts *argv
end

module ConsoleInput
  def self.start_loop ws
    @@ci_thread = Thread.new do
      loop do
        input = gets.strip
        message = ['s', input]
        ChatHandler.handle(message, ws)  # the ws field is left blank because there is no ws
      end
    end
    
    ChatHandler::TRIGGERS << @@handler_trigger = Trigger.new do |t|
      t.match { |info| 
        info[:where] == 's' &&
        info[:what] == 'exit'
      }
      
      t.act { |info|
        log 'exiting console...'
        end_thread
      }
    end
  end
  
  def self.end_thread
    @@ci_thread.exit
    ChatHandler::TRIGGERS.delete(@@handler_trigger)
  end
  
end