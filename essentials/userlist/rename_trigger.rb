require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  t[:id] = 'user_rename'
  
  t.match { |info|
    info[:where].downcase == 'n'
  }
  
  t.act do |info|
    
    oldname = info[:oldname]
    newname = info[:fullwho]
    
    ul = ch.ulhandler.get(info[:room]) 
    ul.get_user(oldname).rename(newname)
    
    ul.trigger_callbacks(:rename, oldname, newname)
    
  end

end