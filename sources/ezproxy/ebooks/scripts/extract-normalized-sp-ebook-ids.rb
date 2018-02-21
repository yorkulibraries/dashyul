#!/usr/bin/env ruby

# Extract basic details (date, user_barcode, book ID) about the books
# viewed on Scholars Portal Books.

require "cgi"
require "csv"
require "date"
require "nokogiri"
require "open-uri"
require "optparse"
require "uri"
require "rubyul"

options = {}
OptionParser.new do |opts|
  opts.on("--ayear AYEAR", "Restrict output to one academic year") do |ayear|
    options[:ayear] = ayear.to_i
  end
  opts.on("--show-errors", "Show all the errors") do
    options[:showerrors] = true
  end
end.parse!

id_map_file = ENV["DASHYUL_DATA"] +
              "/ebooks/scholarsportal/sp-ebook-id-mapping.csv"

STDOUT.sync = true

# Scholars Portal ebooks can have two different IDs: one is numeric
# (like 123456) and the other is the actual file path of the ebook on disk.
# To stop duplication we want to use just one.  As it turns out,
# we can turn the short one into the long one, but not the other
# way around, so the long one is the one we'll use.  To make it easier,
# every time we come across a short numeric ID we'll look up the longer
# complete ID and remember it.  This is stored in this id_map_file,
# which we'll update if needed.
id_map = Hash.new { |h, k| h[k] = {} } # A hash of hashes
CSV.foreach(id_map_file, headers: true, header_converters: :symbol) do |row|
  id_map[row[:numeric_id]][:complete_id] = row[:complete_id]
  id_map[row[:numeric_id]][:title] = row[:title]
end
id_map_changed = false

# Kind of hairy but I only need to pick out three things:
# timestamp, userid (user_barcode) and the requested resource
# (the URI being run through EZProxy).
combined_log_regexp = /
                     (\S+)[[:space:]]
                     (\S+)[[:space:]]
                     (?<userid>\S+)[[:space:]]
                     \[(?<timestamp>.*)\][[:space:]]
                     "
                     (\S+)[[:space:]]
                     (?<resource>.*?)[[:space:]]
                     (\S+)
                     "[[:space:]]
                     (\S+)[[:space:]]
                     (\S+)[[:space:]]
                     "(.*)"[[:space:]]
                     "(.*)"
                     /x

ARGF.each do |line|
  elements = combined_log_regexp.match(line)

  begin
    date = DateTime.strptime(elements[:timestamp],
                             "%d/%B/%Y:%H:%M:%S %z").to_date.to_s

    ayear = Rubyul.academic_year(date)
    next if options[:ayear] && options[:ayear] != ayear

    user_barcode = elements[:userid]

    uri = URI(elements[:resource])

    # Filter out all the stuff we don't care about.  It's nice to
    # take care of this before feeding into this script, but
    # hey, some junk is going to get through.
    next unless %r{scholarsportal.info/viewdoc.html} =~ uri.to_s

    # Sometimes there is no id variable (I'm not sure why); when this happens,
    # skip the line and move on.
    next if uri.query.nil?

    params = CGI.parse(uri.query)
    ebook_uri = uri # For scoping.

    if params.key? "url"
      # This is an EZProxy URI where the ebook URI is in the url variable,
      # so we need to pick that out before proceeding.  I don't know why
      # this happens.
      ebook_uri = URI(params["url"][0])

      # Same case again: may have no CGI parameters.
      next if ebook_uri.query.nil?

      # Now query will hold the CGI parameters that are to be passed
      # in to viewdoc.html.
      params = CGI.parse(ebook_uri.query)
    end

    if params.key? "id"
      # If there is no id variable then something's wrong, but
      # it hardly ever happens, and is probably some misconfiguration,
      # so we'll just skip it.
      ebook_id = params["id"][0]
      if ebook_id.to_i.nonzero?
        # Then it's in the short form, like 37428, so we need to turn
        # it into the complete form.
        if id_map.include? ebook_id
          # It's already known.  Easy peasy lemon squeezy.
          ebook_id = id_map[ebook_id][:complete_id]
        else
          # It's not already known, so pick the information we need
          # out of the contents page.
          doc = Nokogiri::HTML(open(ebook_uri))
          ebook_title = doc.at_css("//head/title")
                          .text
                          .gsub(" - Scholars Portal Books", "")
          # The permalink on the page always points to the complete ID.
          ebook_permalink = doc.at_css("a[text()='Permalink']/@href").value
          permalink_params = CGI.parse(URI(ebook_permalink).query)
          complete_id = permalink_params["id"][0]
          # Add this to the ID map, which we'll write out later.
          id_map[ebook_id][:complete_id] = complete_id
          id_map[ebook_id][:title] = ebook_title
          id_map_changed = true
          ebook_id = complete_id
        end
      end
      puts [date, user_barcode, ebook_id].to_csv
    end
  rescue StandardError => e
    STDERR.puts "ERROR #{uri}: #{e}" if options[:showerrors]
  end
end

# There must be a nice way to append as we go, but I couldn't figure it out.
# Brute force it and rewrite the whole thing when needed.
if id_map_changed
  CSV.open(id_map_file, "w",
           write_headers: true,
           headers: %w[numeric_id complete_id title]) do |csv|
    id_map.each do |numeric_id, details|
      csv << [numeric_id, details[:complete_id], details[:title]]
    end
  end
end
