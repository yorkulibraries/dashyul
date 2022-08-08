#!/usr/bin/env ruby
# frozen_string_literal: true

require "marc"
require "csv"

marcfile = ARGV.first

if marcfile.nil?
  warn "Please specify file"
  exit 0
end

reader = MARC::Reader.new(marcfile, external_encoding: "UTF-8", invalid: :replace)

puts %w[control_number call_number title_author].to_csv

counter = 0

# for record in reader
reader.each do |record|
  begin
    control_number = record["001"].value
    next unless record["949"]

    # puts "245: #{record['245']}"

    title_author = record["245"].to_s.gsub(/.*\$a /, "")
    puts [control_number, record.fields("949").first["a"], title_author].to_csv
  rescue StandardError => e
    warn "Failed on #{control_number}: #{e}"
  end
  counter += 1
  exit if counter == 10
end
