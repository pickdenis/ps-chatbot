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


require "./triggers/bread/breadfinder.rb"
require "./triggers/bread/battles.rb"

Trigger.new do |t| # battles
  t[:id] = 'champ'
  t[:cooldown] = 10 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info| 
    info[:what].downcase =~ /\A(!((who'?s)? ?ch[aiou]mp|(jo+hn)? ?ce+na+))\z/ && $2
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    Battles.get_battles do |battles|
      battle, time = battles.last
      
      result = if battle.nil?
        "couldn't find any battles, sorry"
      else
        time_since = (Time.now - time).to_i / 60 # minutes
        
        if time_since < 1
          time_str = "a few seconds ago"
        else
          time_str = "%d minutes ago"
        end
        
        fmt = if info[:result] =~ /who/
          "THAT QUESTION WILL BE ANSWERED THIS SUNDAY NIIIGHT (%s, posted %s)"
        else
          "champ battle: %s, posted %s."
        end
        
        result = fmt % [battle, time_str % time_since]
      end
      
      info[:respond].call(result)
    end
  end
end
