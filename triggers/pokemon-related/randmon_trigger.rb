



Trigger.new do |t|
  t[:cooldown] = 5 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  t[:id] = "rmon"
  
  t.match { |info|
    (info[:what][0..5] == '!rmon ' && info[:what][6..-1].gsub(/,/, '').split(' ').map(&:strip)) ||
    (info[:what][0..4] == '!rmon' && []) 

  }
  
  t.act do |info|
    # ignores the cooldown check if user is PMing
    if info[:where] != 'pm'
      t[:lastused] + t[:cooldown] < Time.now or next
      t[:lastused] = Time.now
    end
    
    # aliases
    mondata = Pokedex::POKEMONDATA
    fdata = Pokedex::FORMATSDATA
    
    # this will hold the selected mons
    result = []
    
    num, arg1 = nil
    stiers = []
    args = info[:result]
    
    tiers = ['UBER', 'OU', 'UU', 'RU', 'NU', 'LC', 'CAP', 'BL', 'BL2', 'BL3', 'NFE']

    if args[0].to_i > 0
      num = args.shift.to_i
    else
      num = 1
    end
    
    stiers = args.map { |arg|
      (tiers.index(arg.upcase) ? arg.upcase : stiers.index('ANY') ? 'ANY' : nil)
    }.compact
    
    stiers = ['ANY'] if stiers == []
    
    next if num > 6
    
    mons = mondata.keys.keep_if do |mon|
      next if fdata[mon].nil?
      next if (montier = fdata[mon]['tier']).nil?
      
      montier && (stiers.index('ANY') || stiers.index(montier.upcase))
    end
    
    result = mons.sample(num).map { |mon| mondata[mon]['name'] }
    
    info[:respond].call("(#{info[:who]}) #{result.join(', ')} (tiers #{stiers.join(', ')})")
  end
end
