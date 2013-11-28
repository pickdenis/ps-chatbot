require "./bread/breadfinder.rb"
require "./bread/battles.rb"

ChatHandler::TRIGGERS << Trigger.new do |t| # breadfinder
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds
  
  t.match { |info| 
    info[:what].downcase == "!bread"
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or return
    
    t[:lastused] = Time.now
    
    bread = BreadFinder.get_bread
    result = if bread[:no] == 0
      "couldn't find the bread, sorry"
    else
      "bread: http://4chan.org/vp/res/#{bread[:no]}#bottom"
    end
    info[:respond].call(result)
  end
end << Trigger.new do |t| # battles
  t[:lastused] = Time.now
  t[:cooldown] = 10 # seconds
  
  t.match { |info| 
    info[:what].downcase == "!bread"
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or return
    
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