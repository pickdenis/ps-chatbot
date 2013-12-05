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
    
    battles = Battles.get_battles
    
    result = if battles == []
      "couldn't find any battles, sorry"
    else
      "champ battle: #{battles.last}"
    end
    
    info[:respond].call(result)
  end
end