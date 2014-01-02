Trigger.new do |t|
  
  t[:id] = "unban"
  
  t.match { |info|
    info[:what] =~ /\A!(?:uab|aub) (.*?)\z/ && $1
  }
  
  banlist_path = './showderp/autoban/banlist.txt'
  FileUtils.touch(banlist_path)
  
  t.act do |info|
    
    # First check if :who is a mod
    
    next unless info[:all][2][0] == '@' || info[:all][2][0] == '#'
    
    # Remove info[:result] from the ban list
    who = info[:result]
    
    info[:respond].call("/roomunban #{who}")

    banlist = File.read(banlist_path).split("\n").delete(CBUtils.condense_name(who))
    
    File.open(banlist_path, "w") do |f|
      f.puts(banlist)
    end
    
  end
end