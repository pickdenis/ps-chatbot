Trigger.new do |t|
  t[:id] = "autoban_join"
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase =~ /\A[jnl]\z/
  }
  
  banlist_path = './showderp/autoban/banlist.txt'
  FileUtils.touch(banlist_path)
  
  t.act do |info|
    
    banlist = File.read(banlist_path).split("\n")
    messages = info[:all]
    
    while messages.size > 0
      if messages.shift.downcase == 'j'
        name = CBUtils.condense_name(messages.shift[1..-1]) # The first character will be ' ' or '+' etc
        info[:respond].call("/roomban #{name}") if banlist.index(name)
      end
    end
  end
end