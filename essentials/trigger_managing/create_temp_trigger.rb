Trigger.new do |t|
  t[:id] = 'tempcreate'
  
  t.match { |info|
    ch.has_access(info[:who]) && info[:what] =~ /\A!load (.*?)\z/ && $1
  }
  
  t.act do |info|
    url = info[:result]
    
    begin
      EM::HttpRequest.new(url).get.callback do |http|
        ch.load_trigger_code(http.response)
        info[:respond].call("Loaded trigger successfully")
      end
    rescue Exception => e
      info[:respond].call("There was an error while loading the trigger.")
      puts e.message
      next
    end
      
  end
end
