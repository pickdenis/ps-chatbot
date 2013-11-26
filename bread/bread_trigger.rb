require "./bread/breadfinder.rb"

ChatHandler::TRIGGERS << Trigger.new do |t|
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds
  
  t.match { |info| 
    info[:what] =~ /where is the bread/i
  }
  
  t.act do |info|
    if t[:lastused] + t[:cooldown] < Time.now
    
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
end