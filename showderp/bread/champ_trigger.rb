require "./showderp/bread/breadfinder.rb"
require "./showderp/bread/battles.rb"

Trigger.new do |t| # battles
  t[:id] = 'champ'
  t[:lastused] = Time.now
  t[:cooldown] = 10 # seconds
  
  t.match { |info| 
    info[:what].downcase == "!champ"
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    battles, time = Battles.get_batt
    
    
    
    result = if battles.nil?
      "couldn't find any battles, sorry"
    else
      # In minutes
      time_since = Time.now(Time.now - time) / (1000 * 60)
      
      "champ battle: #{battles.last}, posted #{time_since} minutes ago."
    end
    
    info[:respond].call(result)
  end
end