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


require 'em-http'

module FCGetter
  URL = "https://docs.google.com/spreadsheet/pub?key=0Apfr8v-a4nORdHVkcjJUTjJrd3hXV1N2T0dIbktuVVE&output=csv"
  
  def self.load_values
    
    @@fcs = {}
    
    EM::HttpRequest.new(URL).get.callback { |http|
      http.response.each_line do |line|
        vals = line.split(',')
        
        name, _, fc = vals
        
        @@fcs[CBUtils.condense_name(name)] = {fc: fc, realname: name}
        
      end
    }
    
  end
  
  def self.get_fc name
    @@fcs[CBUtils.condense_name(name)]
  end
end

Trigger.new do |t|

  t[:id] = 'fc'
  
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds

  t.match { |info|
    info[:what][0..2].downcase == '!fc' && info[:what][3..-1].strip
  }
  
  FCGetter.load_values
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next

    t[:lastused] = Time.now
    
    userfound = false
    
    info[:result] == '' and info[:result] = nil
    who = info[:result] || info[:who] # if no arg specified, then we'll just use whoever asked
    
    entry = FCGetter.get_fc(CBUtils.condense_name(who))
    
    if entry
      realname = entry[:realname]
      fc = entry[:fc]
      
      info[:respond].call("#{realname}'s FC: #{fc}")
    else
      info[:respond].call("No FC for #{who}.")
    end
    
    FCGetter.load_values

  end
end
