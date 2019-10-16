#!/usr/bin/env ruby

# The full data dump is at
# http://www.library.yorku.ca/libstats/reportReturn.do?date1=&date2=&library_id=&location_id=&report_id=DataCSVReport
# but you can't get at it directly because it requires you're logged in

require "csv"

# Fields in the file:
#  0 question_id
#  1 patron_type           <-- use (added 16 Oct 2019)
#  2 question_type         <-- use
#  3 time_spent            <-- use
#  4 question_format       <-- use
#  5 library_name          <-- use
#  6 location_name         <-- use
#  7 language
#  8 added_stamp
#  9 asked_at
# 10 question_time         <-- use (has seconds) but fix
# 11 question_half_hour
# 12 question_date         <-- use but fix
# 13 question_weekday
# 14 initials
# 15 nil
# 16 nil

all_libraries_csv = ARGV[0]

puts %w[timestamp
        question.type
        question.format
        time.spent
        library.name
        location.name
        patron.type
        initials].to_csv

CSV.foreach(all_libraries_csv, headers: true, header_converters: :symbol) do |row|
  timestamp = row[:asked_at]
  # One-digit days are possible in timestamp; prepend 0 if necessary
  timestamp = "0" + timestamp if timestamp.index("/") == 1

  # Before Feb 2011 it was pretty much all test data
  date = Date.strptime(timestamp, "%m/%d/%Y %r")
  next if date < Date.parse("2011-02-01")

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
