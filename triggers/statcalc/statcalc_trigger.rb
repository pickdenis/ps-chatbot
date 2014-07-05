


require './triggers/statcalc/statcalc.rb'

Trigger.new do |t|
  t[:id] = 'statcalc'
  t[:cooldown] = 2 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..4] == 'base:' &&
    info[:what]
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next

    t[:lastused] = Time.now
    info[:respond].call(StatCalc.calc(info[:result]))
  end
end
