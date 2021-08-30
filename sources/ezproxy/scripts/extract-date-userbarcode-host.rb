#!/usr/bin/env ruby

require "csv"
require "date"
require "optparse"
require "uri"
require "rubyul"

options = {}
OptionParser.new do |opts|
  opts.on("--ayear AYEAR", "Restrict output to one academic year") { |ayear| options[:ayear] = ayear.to_i }
  opts.on("--show-errors", "Show all the errors") { options[:showerrors] = true }
end.parse!

STDOUT.sync = true

error_types = Hash.new(0)

ARGF.each do |line|
  # (user_barcode, raw_date, uri) = line.split(/ /)
  elements = /(\S+) (\S+) (\S+) \[(.*)\] "(\S+) (.*?) (\S+)" (\S+) (\S+) "(.*)" "(.*)"/.match(line)

  begin
    date = DateTime.strptime(elements[4], "%d/%B/%Y:%H:%M:%S %z").to_date.to_s
    ayear = Rubyul.academic_year(date)
    next if options[:ayear] && options[:ayear] != ayear

    # Sometimes the barcode is ID29100, not 29100.  Don't know why.
    user_barcode = elements[3].sub(/^ID/, "")

    # Before grokking the URI, wipe out bad characters that may
    # actualy work but technically aren't valid. We only care about
    # the host, so nothing useful is lost. Also fix cases where two
    # URIs got pasted together somehow.
    uri = elements[6].gsub(/["'\\\[\]<>{}]/, "").gsub("http://ezproxy.library.yorku.ca:80http", "http")
    host = URI(uri).host
    next if host == "ezproxy.library.yorku.ca"

    puts [date, user_barcode, host].to_csv
  rescue StandardError => e
    STDERR.puts e.to_s if options[:showerrors]
    error_types[e.class] += 1
  end
end

STDERR.puts error_types
