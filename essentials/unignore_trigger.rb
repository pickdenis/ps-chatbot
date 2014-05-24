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
  t[:id] = 'unignore'
  t[:nolog] = true
  
  access_path = "./#{ch.dirname}/accesslist.txt"
  FileUtils.touch(access_path)
  t[:who_can_access] = File.read(access_path).split("\n")
  
  t.match { |info| 
    
    
    who = CBUtils.condense_name(info[:who])
    if (info[:where] == 'pm' && t[:who_can_access].index(who)) || info[:where] == 's'
      info[:what] =~ /\Aunignore (.*?)\z/
      $1
    end
  }
  
  t.act { |info| 
    realname = CBUtils.condense_name(info[:result])
    
    if info[:ch].ignorelist.delete(realname)
      info[:respond].call("Removed #{info[:result]} from ignore list. (case insensitive)")
    else
      info[:respond].call("#{info[:result]} is not on the ignore list")
    end
  }
end
