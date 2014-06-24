Trigger.new do |t|
  t[:id] = 'reload'
  
  access_path = "./#{ch.dirname}/accesslist.txt"
  FileUtils.touch(access_path)
  t[:who_can_access] = File.read(access_path).split("\n")
  
  t.match { |info|
    who = CBUtils.condense_name(info[:who])
    
    if t[:who_can_access].index(who)
      info[:what] =~ /\A!reload (.*?)\z/
      $1
    end
  }
  
  t.act do |info|
    id = info[:result]
    
    res = ch.reload_trigger(id)
    info[:respond].call(res ? "Succesfully reloaded trigger #{id}." : "Trigger #{id} doesn't exist.")
  end
  
end