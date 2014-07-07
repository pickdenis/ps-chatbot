require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  t[:id] = 'user_rename'
  
  t.match { |info|
    info[:where].downcase == 'n'
  }
  
  t.act do |info|
    
    oldname = info[:oldname]
    newname = info[:fullwho]
    
    ch.ulhandler.get(info[:room]).get_user(oldname).rename(newname)
    
  end

end