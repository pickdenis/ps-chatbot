Trigger.new do |t|
  t[:id] = 'reload'
  
  
  t.match { |info|
    ch.has_access(info[:who]) && info[:what] =~ /\A!reload (.*?)\z/ && $1
  }
  
  t.act do |info|
    id = info[:result]
    
    res = ch.reload_trigger(id)
    info[:respond].call(res ? "Succesfully reloaded trigger #{id}." : "Trigger #{id} doesn't exist.")
  end
  
end