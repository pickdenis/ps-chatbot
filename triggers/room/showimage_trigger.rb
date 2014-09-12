require 'fastimage'

Trigger.new do |t|

   t[:id] = "showimage"

   t.match { |info|
      info[:where] == 'c' && info[:what] =~ /\A!si (.*?)\z/ && $1
   }

   t.act do |info|

      next unless info[:all][2][0] =~ /[+%@#]/

      url = info[:result]

      size = FastImage.size(url)

      if size.nil?
         info[:respond].call("Invalid image.")
      else
         info[:respond].call("!showimage #{url}, #{size[0]}, #{size[1]}")
      end

   end
end