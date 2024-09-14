puts "EventManager initialized."

if File.exist? "event_attendees.csv"
  lines = File.readlines "event_attendees.csv"
  lines.each_with_index do |line, index|
    next if index.zero?

    columns = line.split ","
    name = columns[2]
    p name
  end
end
