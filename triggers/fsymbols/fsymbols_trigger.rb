


require './triggers/fsymbols/textgen.rb'

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
