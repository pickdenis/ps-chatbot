require_relative "battles.rb"

$chat << Trigger.new do |t|
  t[:lastused] = Time.now - 10
  t[:cooldown] = 10
  t[:lastbattle] = nil
  t[:first] = true
  
  t.match { |info| 
    info[:where] == 'c'
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    lastbattle = Battles.get_battles.last
    if t[:lastbattle] != lastbattle
      t[:lastbattle] = lastbattle
      if t[:first]
        t[:first] = false
      else
        info[:respond].call("New battle posted in bread: #{lastbattle}")
      end
    end
    
  end
end