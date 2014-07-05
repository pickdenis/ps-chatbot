


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
