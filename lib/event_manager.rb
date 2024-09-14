require "csv"

puts "EventManager initialized."

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0, 5]
end

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]
  zipcode = clean_zipcode(zipcode)
  puts "#{name} - #{zipcode}"
end
