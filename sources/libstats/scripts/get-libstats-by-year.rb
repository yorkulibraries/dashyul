#!/usr/bin/env ruby
# frozen_string_literal: true

# CONFIGURING
#
# Explain about the LIBSTATS_LOGIN_COOKIE.

require "cgi"
require "csv"
require "date"
require "open-uri"
require "optparse"
require "rubyul"

options = {}
options[:ayear] = Rubyul.academic_year(Date.today.to_s)
options[:circ] = true
OptionParser.new do |opts|
  opts.banner = "Usage: get-activity-by-branch.rb [options]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-y", "--ayear yyyy", "Academic year") do |ayear|
    options[:ayear] = ayear.to_i
  end
end.parse!

warn "------"
warn "Started: #{Time.now}"

data_url = "https://www.library.yorku.ca/libstats/reportReturn.do?" \
           "&library_id=&location_id=&report_id=DataCSVReport"

ugly_date_format = "%m/%d/%y %l:%M %p"

start_time = Date.new(options[:ayear], 9, 1).strftime(ugly_date_format)

if options[:ayear] <= 2010
  # Before Feb 2011 it was pretty much all test data
  start_time = Date.new(2011, 2, 1).strftime(ugly_date_format)
end

end_time = Date.new(options[:ayear] + 1, 9, 1).strftime(ugly_date_format)

csv_url = data_url +
          "&date1=#{CGI.escape(start_time)}" \
          "&date2=#{CGI.escape(end_time)}"

warn "Start: #{start_time}. End: #{end_time}." if options[:verbose]

# Get the raw CSV data from LibStats
# Fail in various ways if something goes wrong.

data = ""

begin
  # URI.open(csv_url, "Cookie" => "login=#{ENV['LIBSTATS_LOGIN_COOKIE']}") do |f|
  URI.parse(csv_url).open("Cookie" => "login=#{ENV['LIBSTATS_LOGIN_COOKIE']}") do |f|
    if f.status[0] == "200"
      data = f.read
      # warn data if options[:verbose]
      if data == "\n"
        # LibStats returns a newline if there is no data.
        # Inelegant, but we can deal with it by bailing out.
        warn "Questions: 0" if options[:verbose]
        exit 0
      end
    else
      warn "Could not download data: status #{f.status}"
      exit 0
    end
  end
rescue StandardError => e
  warn "Could not download data: #{e}"
end

# Now we know we have some data, so we can work on it.

puts %w[timestamp question.type question.format time_spent library.name location.name patron_type initials].to_csv

csv = CSV.parse(data, headers: true, header_converters: :symbol)
unless csv.empty?
  csv.each do |row|
    timestamp = row[:asked_at]
    # One-digit days are possible in timestamp; prepend 0 if necessary
    timestamp = "0#{timestamp}" if timestamp.index("/") == 1

    question_type = row[:question_type]
    # Clean up data from before the question_type factors were changed
    question_type = "2. Skill-Based: Tech Support"  if question_type == "2a. Skill-Based: Technical"
    question_type = "3. Skill-Based: Non-Technical" if question_type == "2b. Skill-Based: Non-Technical"
    question_type = "4. Strategy-Based"             if question_type == "3. Strategy-Based"
    question_type = "5. Specialized"                if question_type == "4. Specialized"

    puts [timestamp,
          question_type,
          row[:question_format],
          row[:time_spent],
          row[:library_name],
          row[:location_name],
          row[:patron_type],
          row[:initials].to_s.upcase].to_csv
  end
end

warn "Finished: #{Time.now}"
