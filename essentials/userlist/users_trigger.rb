require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  
  t[:id] = 'start_users'
  
  t.match { |info|
    info[:where].downcase == 'users'
  }
  
  t.act do |info|
    info[:what].split(',')[1..-1].each do |name|
      ch.ulhandler.get(info[:room]).add_user(name)
    end
    
  end

end