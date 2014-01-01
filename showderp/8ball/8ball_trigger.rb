Trigger.new do |t|
  t[:id] = "8ball"
  
  responses = IO.readlines('showderp/8ball/responses.txt').map(&:chomp)
  
  t.match { |info|
    info[:what][0..5].downcase == '!8ball'
  }
  
  t.act do |info|
    info[:respond].call("(#{info[:who]}) #{responses.sample}")
  end
end
  
  