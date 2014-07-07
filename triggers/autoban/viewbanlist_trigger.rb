

require './triggers/autoban/banlist.rb'

Trigger.new do |t|
  t[:id] = "viewbanlist"
  t[:nolog] = true
  
  t.match { |info|
    (info[:where].downcase == 'pm' || info[:where] == 's') &&
    info[:what] =~ /^banlist (.*?)$/ && $1
  }
  
  uploader = CBUtils::HasteUploader.new
  
  t.act do |info|
    room = $1
    bl = ch.blhandler.get($1)
    ul = ch.ulhandler.get($1)
    
    if !bl
      info[:respond].call("I don't have a banlist for that room.")
      next
    end
    
    next if !ul
    
    if !['#', '@', '%'].index(ul.get_user_group(info[:who]))
      info[:respond].call("I can't let you see that.")
      next
    end

    
    uploader.upload(bl.to_s) do |url|
      info[:respond].call(url)
    end
    
  end
end
