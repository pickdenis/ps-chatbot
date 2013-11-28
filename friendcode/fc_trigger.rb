require "google_drive"

ChatHandler::TRIGGERS << Trigger.new do |t|

  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds

  t.match { |info|
    (info[:what][0..2].downcase == '!fc' && info[:what][4..-1])
  }

  session = GoogleDrive.login("pickmydenis@gmail.com", "killer horse eats penguins")
  ws = session.spreadsheet_by_key("0Apfr8v-a4nORdHVkcjJUTjJrd3hXV1N2T0dIbktuVVE").worksheets[0]

  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next

    t[:lastused] = Time.now
    
    userfound = false

    who = info[:result] || info[:who] # if result is nil, then we'll just use whoever asked

    ws.reload()

    ws.rows.each do |row|
      if row[1].gsub(/[^\w\d]/, '').downcase == who.gsub(/[^\w\d]/, '').downcase
        info[:respond].call("#{row[0]}'s FC: #{row[2]}")
        userfound = true
      end
    end
    
    userfound or info[:respond].call("User #{who} not found.")

  end
end
