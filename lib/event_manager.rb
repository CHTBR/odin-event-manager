require "csv"
require "yaml"
require "google/apis/civicinfo_v2"

puts "EventManager initialized."

def load_api_key(key_name)
  data = File.read "api_keys.yml"
  data = YAML.load data
  data[key_name]
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0, 5]
end

def request_legislator_names(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = load_api_key("google-civic-info-key")

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"]
    )
    legislators.officials.map(&:name).join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

template_letter = File.read "form_letter.html"

contents.each do |row|
  # name = row[:first_name]
  # zipcode = clean_zipcode(row[:zipcode])
  # legislator_names = request_legislator_names(zipcode)
  # puts "#{name} - #{zipcode} - #{legislator_names}"
  personal_letter = template_letter.gsub("FIRST_NAME", name)
  personal_letter = personal_letter.gsub("LEGISLATORS", legislator_names)

  puts personal_letter
end
