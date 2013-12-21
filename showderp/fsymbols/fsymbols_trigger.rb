require './showderp/fsymbols/textgen.rb'

Trigger.new do |t|
  t[:who_can_access] = ['pick', 'stretcher', 'Scotteh']
  t[:id] = 'fsym'
  
  t.match { |info|
    info[:what][0..4] == '!fsym' &&
    t[:who_can_access].index(info[:who]) && # necessary guard
    info[:what][6..-1]
  }
  
  t.act do |info|
    FSymbols.convert(info[:result]).each do |line|
      info[:respond].call(line)
    end
  end
end
