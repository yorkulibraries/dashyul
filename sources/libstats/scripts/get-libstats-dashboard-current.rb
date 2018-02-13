#!/usr/bin/env ruby

# CONFIGURING
#
# Explain about the LIBSTATS_LOGIN_COOKIE.

require "cgi"
require "csv"
require "date"
require "open-uri"
require "optparse"

options = {}
options[:minutes] = 30
options[:circ] = FALSE
OptionParser.new do |opts|
  opts.banner = "Usage: get-activity-by-branch.rb [options]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-m", "--minutes m", "Minutes to capture") do |m|
    options[:minutes] = m.to_i
  end
  opts.on("c", "--circ", "Include circulation desks") do
    options[:circ] = TRUE
  end
end.parse!

data_url = "https://www.library.yorku.ca/libstats/reportReturn.do?" \
           "&library_id=&location_id=&report_id=DataCSVReport"

ugly_date_format = "%m/%d/%y %l:%M %p"

end_time   = Time.now.strftime(ugly_date_format)
start_time = Date.today.strftime(ugly_date_format) # Midnight today

csv_url = data_url +
          "&date1=#{CGI.escape(start_time)}" \
          "&date2=#{CGI.escape(end_time)}"

warn "Start: #{start_time}. End: #{end_time}." if options[:verbose]

puts %w[timestamp time library.name location.name question.type question.format].to_csv

# Get the raw CSV data from LibStats
# Fail in various ways if something goes wrong.

data = ""

begin
  open(csv_url, "Cookie" => "login=#{ENV['LIBSTATS_LOGIN_COOKIE']}") do |f|
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

csv = CSV.parse(data, headers: true, header_converters: :symbol)
unless csv.empty?
  csv.each do |row|
    timestamp = row[:asked_at]
    # One-digit days are possible in timestamp; prepend 0 if necessary
    timestamp = "0" + timestamp if timestamp.index("/") == 1

    time = case row[:time_spent]
           when "0-1 minute"    then 1
           when "1-5 minutes"   then 3
           when "5-10 minutes"  then 8
           when "10-20 minutes" then 15
           when "20-30 minutes" then 25
           when "30-60 minutes" then 40
           when "60+ minutes"   then 65
           end

    puts [
      timestamp,
      time,
      row[:library_name],
      row[:location_name],
      row[:question_type],
      row[:question_format]
    ].to_csv
  end
end
