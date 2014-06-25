Trigger.new do |t|
  t[:id] = 'toggletrigger'
  
  t.match { |info|
    ch.has_access(info[:who]) && info[:what] =~ /\A!toggle (.*?)\z/ && $1
  }
  
  t.act do |info|
    id = info[:result]
    t = ch.get_by_id(id)
    if !t
      info[:respond].call("'#{id}' is not any trigger's ID")
      next
    end
    
    t[:off] = !t[:off]
    
    info[:respond].call("Trigger '#{t}' turned #{t[:off] ? 'off' : 'on'}.")
    
  end
end