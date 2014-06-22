require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  t[:priority] = 1
  t[:id] = 'userlist_initializer'
  
  t.match { |info|
    info[:where] =~ /users|c|j|l|n/i && !ULHandler::Lists[info[:room]]
  }
  
  t.act do |info|
    room = info[:room]
    
    ULHandler.initialize_list(room)
  end
end