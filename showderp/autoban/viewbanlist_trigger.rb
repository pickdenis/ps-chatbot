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

require './showderp/autoban/banlist.rb'

Trigger.new do |t|
  t[:id] = "banlist"
  t[:nolog] = true
  t[:who_can_access] = ['stretcher', 'pick', 'scotteh']
  
  t.match { |info|
    (info[:where].downcase == 'pm' || info[:where] == 's') &&
    info[:what].downcase == 'blist'
  }
  
  uploader = CBUtils::HasteUploader.new
  
  t.act do |info|
    next unless info[:all][2][0] =~ /[%@#]/ || !!t[:who_can_access].index(CBUtils.condense_name(info[:who]))
    banlist = Banlist.list.join("\n")
    
    banlist_text = if banlist.strip.empty?
      'nobody'
    else
      banlist
    end
    
    uploader.upload(banlist_text) do |url|
      info[:respond].call(url)
    end
    
  end
end
