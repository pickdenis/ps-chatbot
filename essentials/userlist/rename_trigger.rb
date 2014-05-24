require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  
  t.match { |info|
    info[:where].downcase == 'n'
  }
  
  t.act do |info|
    Userlist.remove_by_name(info[:oldname])
    Userlist.add_user(info[:fullwho])
    
  end

end