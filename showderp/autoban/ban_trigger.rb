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
  
  t[:id] = "ban"
  
  t.match { |info|
    info[:what] =~ /\A!ab ([^,]+)\z/ && $1
  }
  
  banlist_path = './showderp/autoban/banlist.txt'
  FileUtils.touch(banlist_path)
  
  t.act do |info|
    
    # First check if :who is a mod
    
    next unless info[:all][2][0] == '@' || info[:all][2][0] == '#'
      
    # Add info[:result] to the ban list
  
    who = CBUtils.condense_name(info[:result])
    
    info[:respond].call("/roomban #{who}")
    
    next if File.read(banlist_path).split("\n").index(who)
    
    File.open(banlist_path, "a") do |f|
      f.puts(who)
    end
    info[:respond].call("Added #{who} to list.")
    
    
    
  end
end
