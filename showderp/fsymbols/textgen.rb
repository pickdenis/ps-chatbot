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


# All character data from http://fsymbols.com/generators/tarty/

module FSymbols
  BASEPATH = File.expand_path(File.dirname(__FILE__))

  SUPPORTEDCHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.!?=:)(><\"'- "
  CHARDATA = Hash[IO.readlines("#{BASEPATH}/chars.txt").each_slice(4).map.with_index { |slice, index|
    [SUPPORTEDCHARS[index], slice[0..2].map(&:chomp)]
  }]
  
  def self.convert text
    result = ["", "", ""]
    text.each_byte do |b|
      data = CHARDATA[b.chr] || next
      result[0] << data[0]
      result[1] << data[1]
      result[2] << data[2]
    end
    
    result
  end
end
