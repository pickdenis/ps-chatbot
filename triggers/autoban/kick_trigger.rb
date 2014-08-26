

Trigger.new do |t|
  
  t[:who_can_access] = ['stretcher', 'pick', 'scotteh']
  
  t[:id] = 'kick'
  
  t.match { |info|
    info[:what] =~ /\A!rk ([^,]+)\z/ && $1
  }
  
  
  t.act do |info|
    
    # First check if :who is a mod (or part of the epic meme police)
    next unless info[:fullwho][0] =~ /[@#]/ || !!t[:who_can_access].index(CBUtils.condense_name(info[:who]))
      
    # Add :result to the ban list
  
    who = CBUtils.condense_name(info[:result])
    
    info[:respond].call("/roomban #{who}")
    
    EM.add_timer(1) do
      info[:respond].call("/roomunban #{who}")
    end
    
  end
end
