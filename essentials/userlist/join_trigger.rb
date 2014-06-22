require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  
  t.match { |info|
    info[:where].downcase == 'j'
  }
  
  t.act do |info|
    ULHandler::Lists[info[:room]].add_user(info[:fullwho])
  end

end