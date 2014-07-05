




Trigger.new do |t|
  t[:id] = 'unignore'
  t[:nolog] = true
  
  t.match { |info| 
    ch.has_access(info[:who]) && info[:what] =~ /\A!unignore (.*?)\z/ && $1
  }
  
  t.act { |info| 
    realname = CBUtils.condense_name(info[:result])
    
    if info[:ch].ignorelist.delete(realname)
      info[:respond].call("Removed #{info[:result]} from ignore list. (case insensitive)")
    else
      info[:respond].call("#{info[:result]} is not on the ignore list")
    end
  }
end
