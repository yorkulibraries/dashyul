#!/usr/bin/env ruby

# Pull some numbers from YorkSpace monthly reports
# and add them together so there's something interesting
# to show in the dashboard.
#
# William Denton <wdenton@yorku.ca>

require "date"
require "open-uri"
require 'optparse'

yorkspace_stats_url_raw = "http://yorkspace.library.yorku.ca/stats/::TYPE::/::TYPE::-::MONTH::.txt"

# Build up the array of months we're going to grab.

academic_year = 2017
# TODO Have it calculate the current year?
month_to_get = Date.new(academic_year, 9, 1)

options = {}
options[:minutes] = 30
options[:circ] = FALSE
OptionParser.new do |opts|
  opts.banner = "Usage: get-yorkspace-numbers.rb [options]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

report_months = []

while month_to_get <= Date.today
  report_months << month_to_get.strftime("%Y-%m")
  month_to_get = month_to_get.next_month
end

# Items added.
#
# Just one number per month that needs to be picked out
# and added up.
#
# The reports look like this:
#   ITEMS ADDED FOR 2016-09
# -------------------------
#                       519
# (1 row)
#
# We just want that third line.

STDERR.puts "Items added:" if options[:verbose]

stats_url = yorkspace_stats_url_raw.gsub("::TYPE::", "items_added")

total_items_added = 0

report_months.each do |month|
  begin
    report = open(URI(stats_url.gsub("::MONTH::", month))).read
    # Check it didn't 404 etc.
    items_added = report.split("\n")[2].to_i
    total_items_added += items_added
    STDERR.puts "  #{month} #{items_added}" if options[:verbose]
  rescue StandardError => e
    STDERR.puts "  #{month} #{e}"
  end
end

# Author downloads
#
# This report has one number per line we need to pick out (after
# throwing out the header).
#
# id   | value                                    | sum
# -----+------------------------------------------+----
# 2038 | Harris, H.S.                             | 2986
# 81   | Katz, Joel                               | 2839
# 2037 | Ontario Committee on the Status of Women | 2322
#
# We need to total all the values in the "sum" column

STDERR.puts "Author downloads:" if options[:verbose]

stats_url = yorkspace_stats_url_raw.gsub("::TYPE::", "author_downloads")

total_author_downloads = 0

report_months.each do |month|
  # Check it didn't 404 etc.
  begin
    open(URI(stats_url.gsub("::MONTH::", month))) do |f|
      f.each_line do |line|
        # We could throw out the first two lines with
        # next if line =~ /handle_id/
        # next if line =~ /\-\|\-/
        # But we don't need to: splitting on | may return a
        # nil for the lines we don't want, but forcing
        # it .to_i turns it to 0, so summing it up works.
        # So we can just do the same thing to every line.
        # name = line.split("|")[1].to_s.slice(0, 30)
        author_downloads = line.split("|")[2].to_i
        total_author_downloads += author_downloads
        # STDERR.puts "  #{month} #{author_downloads} #{name}"
      end
      STDERR.puts "  #{month} #{total_author_downloads}" if options[:verbose]
    end
  rescue StandardError => e
    STDERR.puts "  #{month} #{e}"
  end
end

puts "items_added,author_downloads"
puts "#{total_items_added},#{total_author_downloads}"
