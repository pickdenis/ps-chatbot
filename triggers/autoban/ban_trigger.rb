require "./triggers/autoban/banlist.rb"


Trigger.new do |t|


  t[:id] = 'ban'
  

  t.match { |info|
    info[:what] =~ /\A!ab(q?) ([^,]+)(?:,\s*(.*?))?\z/ && [$1, $2, $3]
  }


  t.act do |info|
    quiet, name, reason = info[:result]
    
    # First check if :who is a mod
    
    next unless info[:fullwho][1] =~ /[@#]/
    
    if !reason
      info[:respond].call('Please supply a reason for the ban.')
      next
    end
    # Add :result to the ban list
    
    bl = ch.blhandler.get(CBUtils.condense_name(info[:room]))
    
    name = CBUtils.condense_name(name)
    actor = CBUtils.condense_name(info[:who])
    
    if quiet != 'q'
      info[:respond].call("/roomban #{name}")
    end
    
    if !bl.has(name)
      bl.ab(name, reason, actor)
      info[:respond].call("#{name} added to list by #{info[:who]}.")
    else
      info[:respond].call("#{name} is already on the list.")
    end
    
  end
end

