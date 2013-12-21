require "./showderp/bread/breadfinder.rb"
require "./showderp/bread/battles.rb"

Trigger.new do |t| # battles
  t[:id] = 'champ'
  t[:cooldown] = 10 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info| 
    info[:what].downcase == "!champ"
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    battles, time = Battles.get_battles.last
    
    
    result = if battles.nil?
      "couldn't find any battles, sorry"
    else
      time_since = (Time.now - time).to_i / 60 # minutes
      
      "champ battle: #{battles}, posted #{time_since} minutes ago."
    end
    
    info[:respond].call(result)
  end
end