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
    
    id = ch.id
    
    if cfg['autoban']
      storage = (cfg['autoban']['storage'] || 'local').to_sym
      if storage == :redis && !CBUtils.connected_to_redis?
        # Huge problem
        $stderr.puts("#{id}: banlist: Tried to use :redis for banlist but wasn't connected. Defaulting to :local (check config file/redis server)")
        $stderr.puts("#{id}: banlist: If you don't know what Redis is at this point, you should just leave things how they are; nothing will go wrong")
        storage = :local
      end
    else
      storage = :local
    end
    
    
    ch.blhandler.initialize_list(room, storage, id)
  end
  
  t.exit do |canreturn|
    id = ch.id
    print "#{id}: banlist: saving... "
    left = ch.blhandler.lists.size
    canreturn.call(true) if left <= 0
    
    ch.blhandler.lists.each do |room, list|
      list.update_file do |resp|
        if !resp
          $stderr.puts("\n#{id}: Warning: Couldn't save banlist for room '#{room}'")
        end
        left -= 1
        if left <= 0
          puts 'done'
          canreturn.call(true)
        end
      end
    end
  end
end