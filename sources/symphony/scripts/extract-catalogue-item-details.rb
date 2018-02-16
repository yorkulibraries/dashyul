#!/usr/bin/env ruby

# Pick item details out of MARC records, from the 999.
# These are the parts of a 999 line:
#
# a CALL NUMBER
# c COPY
# d LAST/ACTIVITY DATE
# e DATE/LAST/CHARGED
# f DATE UINVENTORIED
# g TIMES INVENTORIED
# i BARCODE
# j NUMBER OF PIECES
# k CURRENT LOCATION
# l HOME LOCATION
# m LIBRARY
# n TOTAL CHARGES
# o ITEM EXTENDED INFO
# p PRICE
# q INHOUSE CHARGES
# r CIRULATE FLAG
# s PERMANENCE FLAG
# t ITEM TYPE
# u ACQ_DATE
# v VOL/PART
# w CLASS SCHEME
# STDERR.puts "#{n['i']}"

require "marc"
require "date"
require "csv"

file = ARGV.first

if file.nil?
  STDERR.puts "Please specify file"
  exit 0
end

def convert_date(d)
  Date.parse(d) if d && !d.empty?
end

reader = MARC::Reader.new(file, external_encoding: "UTF-8", invalid: :replace)

puts %w[item_barcode control_number call_number lc_letters lc_digits copy
        last_activity_date date_last_charged date_inventoried
        times_inventoried number_of_pieces current_location
        home_location library total_charges item_extended_info
        price inhouse_charges circulate_flag permanence_flag item_type
        acq_date vol_part class_scheme].to_csv

for record in reader
  next unless record["999"]
  sirsi_number = record.fields("035").find { |c| /Sirsi/.match(c["a"]) }
  control_number = sirsi_number["a"].gsub(/.* /, "")
  # title_author = record['245'].to_s.gsub(/.*\$a /, "")

  record.fields("999").each do |n|
    lc_letters = nil
    lc_digits = nil
    call_number = n["a"]
    if /LC/ =~ n["w"]
      lc_parts = call_number.split(/ /)
      lc_letters = lc_parts[0]
      lc_digits = lc_parts[1]
    end

    puts [n["i"], control_number, call_number,
          lc_letters, lc_digits, n["c"],
          convert_date(n["d"]), convert_date(n["e"]), convert_date(n["f"]),
          n["g"], n["j"], n["k"],
          n["l"], n["m"], n["n"],
          n["o"], n["p"], n["q"],
          n["r"], n["s"], n["t"],
          convert_date(n["u"]), n["v"], n["w"]].to_csv
  end
end
