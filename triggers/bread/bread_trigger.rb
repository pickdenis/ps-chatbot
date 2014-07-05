


require "./triggers/bread/breadfinder.rb"
require "./triggers/bread/battles.rb"


Trigger.new do |t| # breadfinder
  t[:id] = 'bread'
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds
  
  t.match { |info| 
    info[:where] == 'pm' && info[:what].downcase =~ /\A(!bread|!thread)/
  }
  
  t.act do |info|
    
    t[:lastused] + t[:cooldown] < Time.now or next # This should break out of the block
      
    t[:lastused] = Time.now
      
    BreadFinder.get_bread do |bread|
      result = if bread[:no] == 0
        "couldn't find the bread, sorry"
      else
        "bread: http://boards.4chan.org/vp/thread/#{bread[:no]}#bottom"
      end
      info[:respond].call(result)
    end
  end
end
