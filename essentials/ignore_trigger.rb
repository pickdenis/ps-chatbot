


Trigger.new do |t|
  t[:id] = 'ignore'
  t[:nolog] = true
  
  t.match { |info|
    ch.has_access(info[:who]) && info[:what] =~ /\A!ignore (.*?)\z/ && $1
  }
  
  t.act { |info| 
    realname = CBUtils.condense_name(info[:result])
    
    if info[:ch].ignorelist.index(realname)
      info[:respond].call("#{info[:result]} is already on the ignore list.")
    else
      info[:ch].ignorelist << realname
      info[:respond].call("Added #{info[:result]} to ignore list. (case insensitive)")
    end
  }
end
