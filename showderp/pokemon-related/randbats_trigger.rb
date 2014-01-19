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


require './showderp/pokemon-related/pokedata.rb'

Trigger.new do |t|
  t[:id] = "rspd"
  
  t.match { |info|
    info[:what] =~ /\A!rsp[de] (.*?)\z/ && $1
  }
  
  t.act do |info|
    rspd = Pokedex::RANDBATS_SPEEDS
    
    result = rspd[info[:result].downcase.gsub(/[^\w]/, '')]
    
    result = if result.nil?
      ""
    else
      "In randbats, #{info[:result].capitalize}'s speed is #{result}."
    end
    
    
    info[:respond].call(result)
  end
end
