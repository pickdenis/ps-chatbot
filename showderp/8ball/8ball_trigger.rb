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


Trigger.new do |t|
  t[:id] = "8ball"
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  responses = IO.readlines('showderp/8ball/responses.txt').map(&:chomp)
  
  t.match { |info|
    info[:what][0..5].downcase == '!8ball' && info[:what][-1] == '?'
  }
  
  t.act do |info|
    # ignores the cooldown check if user is PMing
    if info[:where] != 'pm'
      t[:lastused] + t[:cooldown] < Time.now or next
      t[:lastused] = Time.now
    end
    
    info[:respond].call("(#{info[:who]}) #{responses.sample}")
  end
end
  
  
