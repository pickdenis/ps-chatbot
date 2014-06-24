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
require "./triggers/autoban/banlist.rb"


Trigger.new do |t|


  t[:id] = 'ban'
  

  t.match { |info|
    info[:what] =~ /\A!ab(q?) ([^,]+)(?:,\s*(.*?))?\z/ && [$1, $2, $3]
  }


  t.act do |info|
    quiet, name, reason = info[:result]
    
    # First check if :who is a mod
    
    next unless info[:all][2][0] =~ /[@#]/
    
    if !reason
      info[:respond].call('Please supply a reason for the ban.')
      next
    end
    # Add :result to the ban list
    
    bl = BLHandler::Lists[CBUtils.condense_name(info[:room])]
    name = CBUtils.condense_name(name)
    actor = CBUtils.condense_name(info[:who])
    
    if quiet != 'q'
      info[:respond].call("/roomban #{name}")
    end
    
    if !bl.has(name)
      bl.ab(name, reason, actor)
      info[:respond].call("#{name} added to list by #{info[:who]}.")
    else
      info[:respond].call("#{name} is already on the list.")
    end
    
  end
end

