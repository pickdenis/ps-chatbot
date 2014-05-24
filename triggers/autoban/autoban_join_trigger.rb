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
require './triggers/autoban/banlist.rb'

Trigger.new do |t|
  t[:id] = "autoban_join"
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase == 'j'
  }
  
  
  t.act do |info|
    
    banlist = Banlist.list
    who = CBUtils.condense_name(info[:who])
    
    info[:respond].call("/roomban #{who}") if banlist.index(who)
  end
end
