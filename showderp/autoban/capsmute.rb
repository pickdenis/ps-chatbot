Trigger.new do |t|

  t[:id] = 'capsmute'

  t.match { |info|
    info[:where] == 'c'
  } 


  t.act { |info|

  	msg = info[:what]
		capsInStr = msg.sub(/[^A-Za-z]/, '')
		capsMatch = capsInStr.match(/[A-Z]+/)

    who = CBUtils.condense_name(info[:who])

    if (msg.to_s.length > 18 && capsMatch.to_s.length >= (msg.to_s.length * 0.8).floor)

	    info[:respond].call("/m #{who}, automated response: caps")

	  end

  }

end