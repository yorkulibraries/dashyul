#!/usr/bin/env ruby

require "marc"
require "csv"

marcfile = ARGV.first

if marcfile.nil?
  STDERR.puts "Please specify file"
  exit 0
end

reader = MARC::Reader.new(marcfile, external_encoding: "UTF-8", invalid: :replace)

puts %w[control_number call_number title_author].to_csv

for record in reader
  begin
    sirsi_number = record.fields("035").find { |c| /Sirsi/.match(c["a"]) }
    control_number = sirsi_number["a"].gsub(/.* /, "")
    next unless record["999"]
    title_author = record["245"].to_s.gsub(/.*\$a /, "")
    puts [control_number, record.fields("999").first["a"], title_author].to_csv
  rescue StandardError => e
    STDERR.puts "Failed on #{control_number}: #{e}"
  end
end
