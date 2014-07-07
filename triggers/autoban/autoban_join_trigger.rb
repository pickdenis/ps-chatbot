

require './triggers/autoban/banlist.rb'

Trigger.new do |t|
  t[:id] = "autoban_join"
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase == 'j'
  }
  
  
  t.act do |info|
    banlist = ch.blhandler.get(info[:room])
    who = CBUtils.condense_name(info[:who])
    
    info[:respond].call("/roomban #{who}") if banlist.has(who)
  end
end
