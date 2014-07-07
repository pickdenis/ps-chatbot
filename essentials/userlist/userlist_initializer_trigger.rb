require './essentials/userlist/userlist.rb'

ch.instance_exec do
  @ulhandler = ULHandler.new
  self.class.send(:attr_accessor, :ulhandler)
end

Trigger.new do |t|
  t[:priority] = 1
  t[:id] = 'userlist_initializer'
  
  t.match { |info|
    info[:where] =~ /users|c|j|l|n/i && !ch.ulhandler.get(info[:room])
  }
  
  t.act do |info|
    room = info[:room]
    
    ch.ulhandler.initialize_list(room)
  end
end