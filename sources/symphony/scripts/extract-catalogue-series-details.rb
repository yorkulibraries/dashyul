#!/usr/bin/env ruby

require "marc"
require "csv"

marcfile = ARGV.first

if marcfile.nil?
  STDERR.puts "Please specify file"
  exit 0
end

reader = MARC::Reader.new(marcfile, external_encoding: "UTF-8", invalid: :replace)

puts %w[control_number publisher series_title series_volume url].to_csv

for record in reader
  begin
    sirsi_number = record.fields("035").find { |c| /Sirsi/.match(c["a"]) }
    control_number = sirsi_number["a"].gsub(/.* /, "")

    # Series info
    next unless record["490"] || record["440"]
    series_title = ""
    series_volume = ""
    if record["490"]
      series_title  = record["490"]["a"].to_s
      series_volume = record["490"]["v"].to_s
    else
      series_title  = record["440"]["a"].to_s
      series_volume = record["440"]["v"].to_s
    end

    # URL
    url = record["856"] ? record["856"]["u"].to_s : ""

    # Publisher
    publisher = ""
    if record["260"]
      publisher = record["260"]["b"].to_s
    elsif record["264"]
      publisher = record["264"]["b"].to_s
    end

    puts [control_number, publisher, series_title, series_volume, url].to_csv
  rescue StandardError => e
    STDERR.puts "Failed on #{control_number}: #{e}"
  end
end
