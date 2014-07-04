Trigger.new do |t|
  t[:id] = 'loadfile'
  
  t[:path] = "./#{ch.dirname};./triggers;."
  
  t.match { |info|
    ch.has_access(info[:who]) && info[:what] =~ /\A!loadfile (.*?)\z/ && $1
  }
  
  t.act do |info|
    path = info[:result]
    
    t[:path].split(';').each do |p|
      if !file
        file = Dir["#{p}/#{path}"][0]
        break
      end
    end
    
    if !file
      info[:respond].call("#{path} could not be found.")
      next
    else
      res = ch.load_trigger(file)
    end

    info[:respond].call( res ? "Succesfully loaded trigger" : "There was an error while loading the trigger" )
  end
  
end
