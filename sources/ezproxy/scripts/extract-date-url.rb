#!/usr/bin/env ruby

require "cgi"
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

ezproxy_prefix = "https://ezproxy.library.yorku.ca:443/login?url="
ezproxy_prefix_regex = ezproxy_prefix.gsub("/", "\\/").gsub("?", "\\?")

error_types = Hash.new(0)

puts %w[date url].to_csv

ARGF.each do |line|
  elements = /(\S+) (\S+) (\S+) \[(.*)\] "(\S+) (.*?) (\S+)" (\S+) (\S+) "(.*)" "(.*)"/.match(line)

  next unless elements
  next unless elements[6]

  raw_url = elements[6]
  next unless raw_url =~ /^#{ezproxy_prefix_regex}/

  # Next, ignore some easy stuff.

  # This is called over and over, so drop it before going further.
  next if raw_url =~ %r{www.jstor.org/px/xhr/api/v1/collector}
  next if raw_url =~ %r{google.(com|ca)}
  next if raw_url =~ %r{nextcanada.westlaw.com/V1/Session/ExtendSessionActiveBrowser}

  # Also drop requests for images, Javascript, etc.
  next if raw_url =~ /(css|ico|gif|jpg|js|json|png|svg)$/

  # puts raw_uri

  begin
    date = DateTime.strptime(elements[4], "%d/%B/%Y:%H:%M:%S %z").to_date.to_s
    ayear = Rubyul.academic_year(date)
    next if options[:ayear] && options[:ayear] != ayear

    user_barcode = elements[3]

    # uri = URI(raw_uri).to_s
    # params = CGI::parse(URI(raw_uri).query)
    # puts params
    url = raw_url.gsub(ezproxy_prefix, "")

    puts [date, url].to_csv
  rescue StandardError => e
    STDERR.puts e.to_s if options[:showerrors]
    error_types[e.class] += 1
  end
end

STDERR.puts error_types
