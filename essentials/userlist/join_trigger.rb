require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  t[:id] = 'user_join'
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase == 'j'
  }
  
  t.act do |info|
    ul = ch.ulhandler.get(info[:room])
    fullname = info[:fullwho]
    
    ul.add_user(fullname)
    ul.trigger_callbacks(:join, fullname)
  end

end