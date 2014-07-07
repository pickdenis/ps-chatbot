require './triggers/autoban/banlist.rb'

ch.instance_exec do
  @blhandler = BLHandler.new
  self.class.send(:attr_accessor, :blhandler)
end

Trigger.new do |t|
  t[:priority] = 1
  t[:id] = 'banlist_initializer'
  
  t.match { |info|
    info[:where] =~ /[cjln]/i && !ch.blhandler.get(info[:room])
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
    
    ch.blhandler.initialize_list(room, storage, pw, dirname)
  end
end