Trigger.new do |t|
  t[:id] = 'loadfile'
  
  
  t.match { |info|
    ch.has_access(info[:who]) && info[:what] =~ /\A!loadfile (.*?)\z/ && $1
  }
  
  t.act do |info|
    path = info[:result]
    
    if File.exists?(path)
      res = ch.load_trigger(path)
    else
      file = Dir["./#{ch.dirname}/#{path}"][0]

      if !file
        info[:respond].call("#{path} could not be found.")
        next
      else
        res = ch.load_trigger(file)
      end
    end

    info[:respond].call( res ? "Succesfully loaded trigger" : "There was an error while loading the trigger" )
  end
  
end
