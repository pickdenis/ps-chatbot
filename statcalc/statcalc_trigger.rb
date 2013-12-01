
$chat << Trigger.new do |t|
  t[:id] = 'statcalc'
  
  t.match { |info|
    info[:what][0..4] == 'base:' &&
    info[:what].scan(/[:\+\-\w]+/)
  }
  
  t.act do |info|
    # initialize all variables
    base = 0
    iv = 31.0
    ev = 0.0
    level = 100.0
    modifier = 1.0
    boostmod = 1.0
    hp = false
    as_base = as_uninvested_base = false
    naturemod = 1.1
    plus = minus = 0.0
    
    stat = 0.0
    
    # loop through the list of flags
    info[:result].each do |term|
      case term
      when /base:(\d+)/
        base = $1.to_f
      when /level:(\d+)/
        level = $1.to_f
      when /(?:ev|evs):(\d+)/
        ev = $1.to_f
      when /(?:iv|ivs):(\d+)/
        iv = $1.to_f
      when /\+(\d+)/
        plus = $1.to_f
        boostmod = (plus + 2) / 2
      when /\-(\d+)/
        minus = $1.to_f
        boostmod = 2 / (minus + 2)
      when "doubled"
        modifier *= 2
      when /scarf(ed)?/
        modifier *= 1.5
      when "invested"
        ev = 252
      when "asbase"
        as_base = true
      when "uninvested"
        as_uninvested_base = true
      when /(bad)(nature)?/
        naturemod = 1.0
      when "hp"
        hp = true
      end
    end
    
    # calculate the stats
    stat = !hp ? ((((iv + 2*base + ev/4) * level/100.0 + 5) * modifier * boostmod).to_i * naturemod).to_i
               : ((iv + 2*base + ev/4) * level/100.0 + 10 + level).to_i
        
    if as_base
      if as_uninvested_base
        stat = (((stat.to_f/naturemod - 5) * 100.0/level - iv) / 2).to_i
      else
        stat = (((stat.to_f/naturemod - 5) * 100.0/level - ev/4 - iv) / 2).to_i
      end
      
    end
    
    # format and send the message
    
    result = "#{base.to_i} base stat #{ev == 252 ? 'invested' : ev > 0 ? "at #{ev} evs" : 'uninvested'} "
    
    result << if plus == 0
      if minus == 0
        ""
      else
        "at -#{minus.to_i} "
      end
    else
      "at +#{plus.to_i} "
    end
    
    result << if level != 100
      "at level #{level} "
    end
    
    result << " #{modifier > 1 ? "with a modifier of #{modifier}x" : ''} "
    
    result << if as_base
      "is equivalent to a base stat of #{stat} #{as_uninvested_base ? 'without investment' : 'with same investment'}."
    else
      "results in a stat of #{stat}."
    end
    
    info[:respond].call(result)
  end
end
