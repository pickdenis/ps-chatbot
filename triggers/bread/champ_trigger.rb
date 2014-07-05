


require "./triggers/bread/breadfinder.rb"
require "./triggers/bread/battles.rb"

Trigger.new do |t| # battles
  t[:id] = 'champ'
  t[:cooldown] = 10 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info| 
    info[:what].downcase =~ /\A(!((who'?s)? ?ch[aiou]mp|(jo+hn)? ?ce+na+))\z/ && $2
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    Battles.get_battles do |battles|
      battle, time = battles.last
      
      result = if battle.nil?
        "couldn't find any battles, sorry"
      else
        time_since = (Time.now - time).to_i / 60 # minutes
        
        if time_since < 1
          time_str = "a few seconds ago"
        else
          time_str = "%d minutes ago"
        end
        
        fmt = if info[:result] =~ /who/
          "THAT QUESTION WILL BE ANSWERED THIS SUNDAY NIIIGHT (%s, posted %s)"
        else
          "champ battle: %s, posted %s."
        end
        
        result = fmt % [battle, time_str % time_since]
      end
      
      info[:respond].call(result)
    end
  end
end
