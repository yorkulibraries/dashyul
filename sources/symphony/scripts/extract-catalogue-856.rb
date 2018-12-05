#!/usr/bin/env ruby

# Go through every bib record in a MARC dump (for example, our full
# catalogue) and pull out every 856 $u.
#
# If the URL is from one of our two ways of giving custom ID numbers
# to eresources then pick them out and list them as muler_id or
# muler_alt_id. These will be suitable for matching up with a dump of
# ID numbers from MULER.
#
# muler_id is 2799046: http://www.library.yorku.ca/e/resolver/id/2799046
# muler_alt_id is 9589: http://www.library.yorku.ca/eresolver/?id=9589

require "rubygems"
require "marc"
require "cgi"
require "csv"
require "uri"

STDOUT.sync = true

# 856 - Electronic Location and Access
# http://www.loc.gov/marc/bibliographic/bd856.html

file = ARGV.first

if file.nil?
  STDERR.puts "Please specify file"
  exit 0
end

reader = MARC::Reader.new(file, external_encoding: "UTF-8", invalid: :replace)

puts %w[control_number muler_id muler_alt_id url].to_csv

reader.each do |record|
  begin
    next unless record["856"]

    sirsi_number = record.fields("035").find { |c| /Sirsi/.match(c["a"]) }
    control_number = sirsi_number["a"].gsub(/.* /, "")

    # puts record

    record.fields("856").each do |n|
      # STDERR.puts n
      url = n["u"]
      next unless url

      muler_id = ""
      muler_alt_id = ""

      if url =~ %r{www.library.yorku.ca/e/resolver}
        # http://www.library.yorku.ca/e/resolver/id/2799046
        muler_id = url.split("/").last
      elsif url =~ %r{www.library.yorku.ca/eresolver}
        # http://www.library.yorku.ca/eresolver/?id=9589
        params = CGI.parse(URI(url).query)
        muler_alt_id = params["id"].first
      end

      puts [control_number, muler_id, muler_alt_id, url].to_csv
    end
  rescue StandardError => e
    # There are very few errors; not enough to worry about.
    # If a URL is badly formatted, just forget about it.
    STDERR.puts "Error #{e} on record #{control_number}"
  end
end
