require "./showderp/bread/breadfinder.rb"
require "./showderp/bread/battles.rb"


Trigger.new do |t| # breadfinder
  t[:id] = 'bread'
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds
  
  t.match { |info| 
    info[:what].downcase == "!bread"
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next # This should break out of the block
    
    t[:lastused] = Time.now
    
    bread = BreadFinder.get_bread
    result = if bread[:no] == 0
      "couldn't find the bread, sorry"
    else
      "bread: http://4chan.org/vp/res/#{bread[:no]}#bottom"
    end
    info[:respond].call(result)
  end
end