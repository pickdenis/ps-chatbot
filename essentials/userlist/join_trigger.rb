require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  
  t.match { |info|
    info[:where].downcase == 'j'
  }
  
  t.act do |info|
    Userlist.add_user(info[:fullwho])
  end

end