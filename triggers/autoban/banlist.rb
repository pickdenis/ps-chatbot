

require 'eventmachine'
require 'em-http-request'
require 'fileutils'
require 'yaml'

class Banlist
  
  
  # The room the banlist is in effect in
  
  attr_reader :room
  
  # The method of storage
  # :local means it will be stored in a file locally
  # :central means it will be stored in a central banlist, on google drive
  # If you want to use :central, you need to know the secret password
  
  attr_reader :storage
  
  def initialize room, storage, dirname=nil
    @room = room
    @storage = (storage == :central ? :central : :local)
    
    if @storage == :local
      @blpath = "./#{dirname}/autoban/"
      FileUtils.mkdir_p(@blpath)
      @blpath << "#{@room}.yml"
      FileUtils.touch(@blpath)
    end
    
    get
    
  end
  
  def set_pw pw
    @pw = pw
  end
  
  # The actual list
  
  attr_reader :banlist
  
  def get(&callback)
    @banlist = []
    
    if storage == :central
      # Not implemented yet!
    else
      @banlist = YAML.load(File.open(@blpath)) || []
      @callback.call(@banlist) if block_given?
    end
  end
  
  def get_entry(name)
    @banlist.find { |entry| entry.name == name }
  end
  
  def has(name)
    !!get_entry(name)
  end
  
  def update_file
    File.open(@blpath, 'w') do |f|
      f.puts(YAML.dump(@banlist))
    end
  end
  
  def action(act, name, actor, reason=nil, &callback)
    # name = CBUtils.condense_name(name)
    if act == "ab"
      if !has(name)
        
        entry = BanEntry.new(name, reason, actor)
        
        @banlist << entry
        update_file if storage == :local
        
      end
      
    elsif act == "uab"
      
      @banlist.delete(get_entry(name))
      
      update_file if storage == :local
      
    end
    
    if storage == :central
      # Not implemented yet
    end
  end
  
  def ab(name, reason, actor, &callback)
    action("ab", name, actor, reason, &callback)
  end
  
  def uab(name, reason=nil, actor=nil, &callback)
    action("uab", name, actor, reason, &callback)
  end
  
  def to_s
    @banlist.map(&:to_s).join("\n")
  end
  
end

BanEntry = Struct.new(:name, :reason, :bannedby)

class BanEntry
  def to_s
    "#{name}|#{reason || '<unknown>'} (banned by #{bannedby || '<unknown>'})"
    
  end
end

class BLHandler
  
  def initialize
    @lists = {}
  end
  
  def initialize_list(room, storage, pw, dirname)
    @lists[room] ||= Banlist.new(room, storage, dirname)
    @lists[room].set_pw(pw)
  end
  
  def get(room)
    @lists[room]
  end
  
end