

Trigger.new do |t|
  t[:id] = 'unignore'
  t[:nolog] = true
  
  access_path = './essentials/accesslist.txt'
  FileUtils.touch(access_path)
  t[:who_can_access] = File.read(access_path).split("\n")
  
  t.match { |info| 
    who = CBUtils.condense_name(info[:who])
    if (info[:where] == 'pm' && t[:who_can_access].index(who)) || info[:where] == 's'
      info[:what] =~ /\Aunignore (.*?)\z/
      $1
    end
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