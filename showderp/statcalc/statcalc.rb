# ps-chatbot: a chatbot that responds to commands on Pokemon Showdown chat
# Copyright (C) 2014 pickdenis
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


module StatCalc
  def self.calc str
    # initialize all variables
    o_base = base = 0
    o_iv = iv = 31.0
    o_ev = ev = 0.0
    o_level = level = 100.0
    o_modifier = modifier = 1.0
    o_boostmod = boostmod = 1.0
    o_hp = hp = false
    o_naturemod = naturemod = 1.1
    o_plus = plus = o_minus = minus = 0.0
    asbase = false
    
    
    stat = 0.0
    
    # loop through the list of flags
    str.scan(/[:\+\-\w]+/).each do |term|
      case term
      when /base:(\d+)/
        base = $1.to_f
      when /level:(\d+)/
        o_level = $1.to_f
        level = o_level if !asbase
      when /(?:ev|evs):(\d+)/
        o_ev = $1.to_f
        ev = o_ev if !asbase
      when /(?:iv|ivs):(\d+)/
        o_iv = $1.to_f
        iv = o_iv if !asbase
      when /\+(\d+)/
        if asbase
          o_plus = $1.to_f
          o_boostmod = (o_plus + 2) / 2
        else
          plus = $1.to_f
          boostmod = (plus + 2) / 2
        end
      when /\-(\d+)/
        if asbase
          o_minus = $1.to_f
          o_boostmod = 2 / (o_minus + 2)
        else
          minus = $1.to_f
          boostmod = 2 / (minus + 2)
        end
      when "doubled"
        if asbase
          o_modifier *= 2
        else
          modifier *= 2
        end
      when /scarf(ed)?/
        if asbase
          o_modifier *= 1.5
        else
          modifier *= 1.5
        end
      when "invested"
        o_ev = 252
        ev = 252 if !asbase
      when "uninvested"
        o_ev = 0
        ev = 0 if !asbase
      when "asbase"
        asbase = true
      when /(neutral)(nature)?/
        o_naturemod = 1.0
        naturemod = o_naturemod if !asbase
      when /(bad)(nature)?/
        o_naturemod = 0.9
        naturemod = o_naturemod if !asbase
      when "hp"
        hp = true
      end
    end
    
    # calculate the stats
    stat = !hp ? ((((iv + 2*base + ev/4) * level/100.0 + 5) * modifier * boostmod).to_i * naturemod).to_i
               : ((iv + 2*base + ev/4) * level/100.0 + 10 + level)
    
    
    if asbase
      stat = (((stat.to_f/(o_naturemod)/(o_boostmod)/(o_modifier) - 5) * 100.0/(o_level) - o_ev/4 - o_iv) / 2).to_i + 1
    end
    
    stat = stat.to_i
    
    # format and send the message
    
    result = "#{base.to_i} base stat "
    
    result << generate_modstring(ev.to_i, iv.to_i, plus.to_i, minus.to_i, level.to_i, modifier, naturemod)
    
    if asbase
      result << "is equivalent to a base stat of #{stat} " \
             << generate_modstring(o_ev.to_i, iv.to_i, o_plus.to_i, o_minus.to_i, o_level.to_i, o_modifier, o_naturemod)
      result[-1] = '.' if result[-1] == ' '
    else
      result << "results in a stat of #{stat}#{stat == 420 ? ' (blaze it)' : ''}."
    end
    
    result
  end
  
  def self.generate_modstring ev, iv, plus, minus, level, modifier, naturemod
    modstring = ""
    
    modstring << (ev == 252 ? 'invested ' : ev > 0 ? "at #{ev} evs " : 'uninvested ')
    iv != 31 and modstring << "with #{iv} ivs "
    
    modstring << (plus == 0 ? minus != 0 ? "at -#{minus} " : "" : "at +#{plus} ")
    
    level != 100 and modstring << "at level #{level} "
    
    modifier > 1 and modstring << "with a modifier of #{modifier}x "
    
    naturemod != 1 and modstring << (naturemod > 1 ? 'with a boosting nature ' : naturemod < 1 ? 'with a hindering nature ' : ' ')
    
    modstring
  end
end
