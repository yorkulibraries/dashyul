#!/usr/bin/env ruby

require 'cgi'
require 'csv'
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

id_map = {}

# CSV.foreach("sp-ebook-id-mapping.csv", {:headers => true, :header_converters => :symbol}) do |row|
#   id_map[row[:common_id]] = row[:ebook_id]
# end

puts ['date', 'user_barcode', 'ebook_id'].to_csv

ARGF.each do |line|

  elements = /(\S+) (\S+) (\S+) \[(.*)\] "(\S+) (.*?) (\S+)" (\S+) (\S+) "(.*)" "(.*)"/.match(line)

  begin

    date = DateTime.strptime(elements[4], '%d/%B/%Y:%H:%M:%S %z').to_date.to_s
    ayear = academic_year(date)
    next if options[:ayear] && options[:ayear] != ayear

    user_barcode = elements[3]

    uri = URI(elements[6])

    # Sometimes there is no id variable (I'm not sure why); when this happens,
    # skip the line and move on.
    next if uri.query.nil?

    params = CGI::parse(uri.query)

    if params.has_key? "url"
      # This is an EZProxy URI where the ebook URI is in the url variable,
      # so we need to pick that out before proceeding.
      ebook_uri = URI(params["url"][0])
      # STDERR.puts "SP URI: #{ebook_uri}"

      # Same case again: may have no CGI parameters.
      next if ebook_uri.query.nil?

      # Now query will hold the CGI parameters that are to be passed in to viewdoc.html
      params = CGI::parse(ebook_uri.query)
    end

    if params.has_key? "id"
      ebook_id = params['id'][0]
      if id_map.include? ebook_id
        # Convert /ebooks/ebooks0/gibson_crkn/2009-12-01/5/412078 to 37428 for simplicity and normalization.
        ebook_id = id_map[ebook_id]
      end
      puts [date, user_barcode, ebook_id].to_csv
    else
      # STDERR.puts "#{raw_uri} has no id? #{query}"
    end

  rescue Exception => e
    STDERR.puts "ERROR #{uri}: #{e}"
  end

end
