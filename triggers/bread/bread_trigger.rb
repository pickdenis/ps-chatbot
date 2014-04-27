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


Trigger.new do |t| # breadfinder
  t[:id] = 'bread'
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds
  
  t.match { |info| 
    info[:where] == 'pm' && info[:what].downcase =~ /\A(!bread|!thread)/
  }
  
  t.act do |info|
    
    t[:lastused] + t[:cooldown] < Time.now or next # This should break out of the block
      
    t[:lastused] = Time.now
      
    BreadFinder.get_bread do |bread|
      result = if bread[:no] == 0
        "couldn't find the bread, sorry"
      else
        "bread: http://boards.4chan.org/vp/thread/#{bread[:no]}#bottom"
      end
      info[:respond].call(result)
    end
  end
end
