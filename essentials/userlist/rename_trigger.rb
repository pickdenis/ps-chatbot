require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  
  t.match { |info|
    info[:where].downcase == 'n'
  }
  
  t.act do |info|
    Userlist.get_user(info[:oldname]).rename(info[:fullwho])
    
  end

end