Trigger.new do |t|
  
  t[:id] = "ban"
  
  t.match { |info|
    info[:what] =~ /\A!ab ([^,]+)\z/ && $1
  }
  
  banlist_path = './showderp/autoban/banlist.txt'
  FileUtils.touch(banlist_path)
  
  t.act do |info|
    
    # First check if :who is a mod
    
    next unless info[:all][2][0] == '@' || info[:all][2][0] == '#'
      
    # Add info[:result] to the ban list
  
    who = CBUtils.condense_name(info[:result])
    
    info[:respond].call("/roomban #{who}")
    
    next if File.read(banlist_path).split("\n").index(who)
    
    File.open(banlist_path, "a") do |f|
      f.puts(who)
    end
    
    
    
    
  end
end