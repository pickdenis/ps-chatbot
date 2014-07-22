require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  t[:id] = 'user_rename'
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase == 'n'
  }
  
  t.act do |info|
    
    oldname = info[:oldname]
    newname = info[:fullwho]
    
    ul = ch.ulhandler.get(info[:room]) 
    ul.get_user(oldname).rename(newname)
    if CBUtils.condense_name(oldname) != CBUtils.condense_name(newname[1..-1])
      
      ul.trigger_callbacks(:rename, oldname, newname[1..-1])
    end
    
  end

end