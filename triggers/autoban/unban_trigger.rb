require './triggers/autoban/banlist.rb'

Trigger.new do |t|

  t[:id] = 'unban'

  t.match { |info|
    info[:what] =~ /\A!(?:uab|aub)(q?) ([^,]+)\z/ && [$1, $2]
  }

  t.act do |info|
    
    quiet, name = info[:result]

    # First check if :who is a mod

    next unless info[:fullwho][1] =~ /[@#]/

    # Remove :result from the ban list
    bl = ch.blhandler.get(info[:room])
    name = CBUtils.condense_name(name)

    if quiet != 'q'
      info[:respond].call("/roomunban #{name}")
    end
    
    bl.uab(name)

    info[:respond].call("Removed #{name} from list.")


  end
end

