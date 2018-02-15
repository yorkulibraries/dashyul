#!/usr/bin/env ruby

# Convert the Symphony user information dump file to a nicer CSV
#
# It looks like:
# 29007001111111|100111111|FACULTY|YUFA|
# 29007012222222|707222222|UNDERGRAD|GLENDON|
# 29007003333333|400333333|EXTERNAL|ALUMNI|
# 29007004444444|929444444|UNDERGRAD|ATKINSON|

# TODO: Move to use CSV library properly.

file = ARGV.first

if file.nil?
  STDERR.puts "Please specify file"
  exit 0
end

puts "user_barcode,cyin,profile,affiliation"

File.open(file).each do |line|
  pieces = line.split("|")
  puts "#{pieces[0]},#{pieces[1]},#{pieces[2]},#{pieces[3]}"
end
