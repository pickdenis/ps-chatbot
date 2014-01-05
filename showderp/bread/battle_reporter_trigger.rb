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


$LOAD_PATH << '.'

require "./showderp/bread/battles.rb"

Trigger.new do |t|
  t[:lastused] = Time.now - 10
  t[:cooldown] = 10
  t[:prevbattles] = []
  t[:first] = true
  
  t.match { |info| 
    info[:where] == 'c'
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    Battles.get_battles do |battles|
      lastbattle, time = battles.last
    
      if !t[:prevbattles].index(lastbattle)
        t[:prevbattles] << lastbattle
        if t[:first]
          t[:first] = false
        else
          info[:respond].call("New battle posted in bread: #{lastbattle}")
        end
      end
    end
    
  end
end
