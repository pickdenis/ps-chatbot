


Trigger.new do |t|
  t[:id] = "8ball"
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  responses = IO.readlines('./triggers/8ball/responses.txt').map(&:chomp)
  
  t.match { |info|
    info[:what][0..5].downcase == '!8ball' && info[:what][-1] == '?'
  }
  
  t.act do |info|
    # ignores the cooldown check if user is PMing
    if info[:where] != 'pm'
      t[:lastused] + t[:cooldown] < Time.now or next
      t[:lastused] = Time.now
    end
    
    info[:respond].call("(#{info[:who]}) #{responses.sample}")
  end
end
  
  
