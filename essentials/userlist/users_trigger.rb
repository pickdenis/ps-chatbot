require './essentials/userlist/userlist.rb'

Trigger.new do |t|
  
  t.match { |info|
    info[:where].downcase == 'users'
  }
  
  t.act do |info|
    info[:what].split(',')[1..-1].each do |name|
      Userlist.add_user(name)
    end
    
  end

end