require "./triggers/autoban/banlist.rb"

Trigger.new do |t|
  t[:id] = 'checkban'
  
  t.match { |info|
    info[:what] =~ /\A!cb (.*?)\z/ && $1.split(/,\s*/)
  }
  
  t.act do |info|
    args = info[:result]
    
    if info[:where] == 'pm'
      if args.size != 2
        info[:respond].call('PM syntax: !cb <name>, <room>')
        next
      end
    elsif info[:where] == 'c'
      if args.size != 1
        info[:respond].call('Chat syntax: !cb <name>')
        next
      end
      
      args << info[:room]
    end
      
    
    name = CBUtils.condense_name(args.shift)
    room = args.shift
    
    bl = ch.blhandler.get(room)
    ul = ch.ulhandler.get(room)
    
    who = CBUtils.condense_name(info[:who])
    
    if !bl
      info[:respond].call("I don't know of that room.")
      next
    end
    
    if !(ul.get_user_group(who) =~ /[\@\#]/)
      info[:respond].call("I can't let you see that.")
      next
    end
    
    if !bl.has(name)
      info[:respond].call("User #{name} isn't on the list.")
      next
    end
    
    info[:respond].call(bl.get_entry(name).to_s)
  end
end