#!/usr/bin/env ruby

# Add comments!

require 'date'
require 'optparse'
require 'uri'

options = {}
OptionParser.new do |opts|
  opts.on('--ayear AYEAR', 'Restrict output to one academic year') { |ayear| options[:ayear] = ayear.to_i }
  opts.on('--show-errors', 'Show all the errors') { options[:showerrors] = true }
end.parse!

STDOUT.sync = true

def academic_year(date)
  # See https://www.miskatonic.org/2016/09/22/academic-year/
  (Date.parse(date) << 8).year
end

error_types = Hash.new(0)

ARGF.each do |line|
  # (user_barcode, raw_date, uri) = line.split(/ /)
  elements = /(\S+) (\S+) (\S+) \[(.*)\] "(\S+) (.*?) (\S+)" (\S+) (\S+) "(.*)" "(.*)"/.match(line)

  begin

    date = DateTime.strptime(elements[4], '%d/%B/%Y:%H:%M:%S %z').to_date.to_s
    ayear = academic_year(date)
    next if options[:ayear] && options[:ayear] != ayear

    user_barcode = elements[3]

    # Before grokking the URI, wipe out bad characters that may actualy work
    # but technically aren't valid.  We only care about the host, so nothing useful
    # is lost.  Also fix cases where two URIs got pasted together somehow.
    uri = elements[6].gsub(/["'\\\[\]<>{}]/, '').gsub('http://ezproxy.library.yorku.ca:80http', 'http')
    host = URI(uri).host
    next if host == 'ezproxy.library.yorku.ca'

    puts "#{date},#{user_barcode},#{host}"

  rescue StandardError => e
    STDERR.puts "#{e}" if options[:showerrors]
    error_types[e.class] += 1
  end
end

STDERR.puts error_types