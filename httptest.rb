
require 'em-http'

module FCGetter
    URL = "https://docs.google.com/spreadsheet/pub?key=0Apfr8v-a4nORdHVkcjJUTjJrd3hXV1N2T0dIbktuVVE&output=csv"
      
      def self.load_values
            raw = EM::HttpRequest.new(URL).get.callback { |http|
                    puts http.response
                        }
                            
                          end
end

EM.run {
  FCGetter.load_values
}
