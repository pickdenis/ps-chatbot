Trigger.new do |t|
  t[:id] = 'ignore'
  t[:nolog] = true
  
  access_path = './essentials/accesslist.txt'
  FileUtils.touch(access_path)
  t[:who_can_access] = File.read(access_path).split("\n")
  
  t.match { |info| 
    who = CBUtils.condense_name(info[:who])
    
    if info[:where] == 'pm' && t[:who_can_access].index(who) || info[:where] == 's'
      info[:what] =~ /\Aignore (.*?)\z/
      $1
    end
  }
  
  t.act { |info| 
    p info[:result]
    realname = CBUtils.condense_name(info[:result])
    
    if info[:ch].ignorelist.index(realname)
      info[:respond].call("#{info[:result]} is already on the ignore list.")
    else
      info[:ch].ignorelist << info[:result]
      info[:respond].call("Added #{info[:result]} to ignore list. (case insensitive)")
    end
  }
end