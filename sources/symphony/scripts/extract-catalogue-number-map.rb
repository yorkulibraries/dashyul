#!/usr/bin/env ruby

# Generate a long but simple CSV file that maps ISBNs to
# control_numbers and item_numbers (barcodes).

require "marc"
require "csv"

file = ARGV.first

if file.nil?
  STDERR.puts "Please specify file"
  exit 0
end

reader = MARC::Reader.new(file, external_encoding: "UTF-8", invalid: :replace)

puts %w[control_number isbn item_barcode].to_csv

reader.each do |record|
  begin
    sirsi_number = record.fields("035").find { |c| /Sirsi/.match(c["a"]) }
    next unless sirsi_number
    next unless sirsi_number["a"]
    control_number = sirsi_number["a"].gsub(/.* /, "")

    ## STDERR.print "#{control_number}\r"

    # MARC 020 fields can be full of non-ISBN nonsense!
    # Ugh! https://loc.gov/marc/bibliographic/bd020.html
    record.fields("020").each do |twenty|
      next unless twenty["a"]
      # First, get rid of any punctuation, so
      # 0-14-045503-5 becomes 0140455035.
      isbn_field = twenty["a"].gsub(/[[:punct:]]/, "")
      # Now match any and all ISBN-looking things: 10 or 13
      # characters long, all digits except possibly for an X at the
      # end. This will catch invalid ISBNs, but at least they look
      # like ISBNs.
      isbns = isbn_field.scan(/\d{9,12}[\dX]/)
      record.fields("999").each do |nnn|
        # nnn["i"] is the item barcode
        # Print every possible pair of ISBNs and item barcodes
        isbns.each do |isbn|
          puts [control_number, isbn, nnn["i"]].to_csv
        end
      end
    end
  rescue StandardError => e
    STDERR.puts "Error #{e} on record #{control_number}"
  end
end

STDERR.puts
