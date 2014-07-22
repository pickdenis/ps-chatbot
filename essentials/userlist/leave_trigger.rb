require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  t[:id] = 'user_leave'
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase == 'l'
  }
  
  t.act do |info|
    ul = ch.ulhandler.get(info[:room])
    name = info[:who]
    
    ul.remove_by_name(name)
    ul.trigger_callbacks(:leave, name)
  end

end