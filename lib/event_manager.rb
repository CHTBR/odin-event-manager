require "csv"
require "yaml"
require "erb"
require "google/apis/civicinfo_v2"

puts "EventManager initialized."

def load_api_key(key_name)
  data = File.read "api_keys.yml"
  data = YAML.safe_load data
  data[key_name]
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0, 5]
end

def request_legislator_names(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = load_api_key("google-civic-info-key")

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def output_to_file(id, letter)
  Dir.mkdir("output") unless Dir.exist?("output")
  filename = "output/thanks_#{id}.html"
  File.open(filename, "w") do |file|
    file.puts letter
  end
end

def clean_phone_number(number)
  number = number.to_s
  if number.size == 10
    return number.to_i
  elsif number.size == 11 && number[0] == 1
    return number[1, 10].to_i
  end

  "bad number"
end

def convert_to_time(regdate)
  time_array = regdate.split
  time_array = time_array[0].split("/") + time_array[1].split(":")
  time_array[2] = "20" + time_array[2]
  time_array = time_array.map(&:to_i)
  Time.new(time_array[2], time_array[0], time_array[1], time_array[3], time_array[4])
end

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

# template_letter = File.read("form_letter.erb")
# erb_template = ERB.new template_letter

times = Hash.new(0)

days_array = %w[Su Mo Tu We Th Fr Sa]
days = Hash.new(0)

contents.each do |row|
  # name = row[:first_name]
  # zipcode = clean_zipcode(row[:zipcode])
  # legislator_names = request_legislator_names(zipcode)
  # personal_letter = erb_template.result(binding)
  # id = row[0]
  # output_to_file(id, personal_letter)
  time = convert_to_time(row[:regdate])
  times[time.hour] += 1
  days[days_array[Date.new(time.year, time.month, time.day).wday]] += 1
end

pp(times)
pp(days)
