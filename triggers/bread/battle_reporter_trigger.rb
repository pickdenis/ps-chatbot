


require "./triggers/bread/battles.rb"

Trigger.new do |t|
  t[:lastused] = Time.now - 10
  t[:cooldown] = 10
  t[:prevbattles] = []
  t[:first] = true
  
  t.match { |info| 
    info[:where] == 'c'
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    Battles.get_battles do |battles|
      lastbattle, time = battles.last
    
      if !t[:prevbattles].index(lastbattle)
        t[:prevbattles] << lastbattle
        if t[:first]
          t[:first] = false
        else
          info[:respond].call("New battle posted in bread: #{lastbattle}")
        end
      end
    end
    
  end
end
