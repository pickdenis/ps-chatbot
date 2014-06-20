require './triggers/autoban/banlist.rb'

Trigger.new do |t|
  t[:priority] = 1
  t[:id] = 'banlist_initializer'
  
  t.match { |info|
    info[:where] =~ /[cjln]/i && !BLHandler::Lists[info[:room]]
  }
  
  t.act do |info|
    room = info[:room]
    cfg = ch.config
    
    
    if cfg['autoban']
      pw = cfg['autoban']['pw'] || ''
      storage = (cfg['autoban']['storage'] || 'local').to_sym
    else
      pw = ''
      storage = :local
    end
    
    dirname = ch.dirname
    
    BLHandler.initialize_list(room, storage, pw, dirname)
    p BLHandler::Lists
  end
end