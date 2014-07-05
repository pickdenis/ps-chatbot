


require 'em-http'
require './triggers/friendcode/fcgetter.rb'

Trigger.new do |t|

  t[:id] = 'fc'
  
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds

  t.match { |info|
    info[:what][0..2].downcase == '!fc' && info[:what][3..-1].strip
  }
  
  FCGetter.load_values
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next

    t[:lastused] = Time.now
    
    userfound = false
    
    info[:result] == '' and info[:result] = nil
    who = info[:result] || info[:who] # if no arg specified, then we'll just use whoever asked
    
    entry = FCGetter.get_fc(CBUtils.condense_name(who))
    
    if entry
      realname = entry[:realname]
      fc = entry[:fc]
      
      info[:respond].call("#{realname}'s FC: #{fc}")
    else
      info[:respond].call("No FC for #{who}.")
    end
    
    FCGetter.load_values

  end
end
