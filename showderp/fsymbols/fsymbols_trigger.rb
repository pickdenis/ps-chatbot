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


require './showderp/fsymbols/textgen.rb'

Trigger.new do |t|
  t[:who_can_access] = ['pick', 'stretcher', 'scotteh']
  t[:id] = 'fsym'
  
  t.match { |info|
    info[:what][0..4] == '!fsym' &&
    t[:who_can_access].index(CBUtils.condense_name(info[:who])) && # necessary guard
    info[:what][6..-1]
  }
  
  t.act do |info|
    FSymbols.convert(info[:result]).each do |line|
      info[:respond].call(line)
    end
  end
end
