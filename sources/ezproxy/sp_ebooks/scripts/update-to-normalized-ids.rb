#!/usr/bin/env ruby

require "cgi"
require "csv"
require "date"
require "nokogiri"
require "open-uri"
require "optparse"
require "uri"

old_csv_file = ARGV[0]

id_map_file = __dir__ + "/../data/sp-ebook-id-mapping.csv"
id_map = Hash.new { |h, k| h[k] = {} } # A hash of hashes
CSV.foreach(id_map_file, headers: :true, header_converters: :symbol) do |row|
  id_map[row[:numeric_id]][:complete_id] = row[:complete_id]
  id_map[row[:numeric_id]][:title] = row[:title]
end
id_map_changed = false

puts %w(date user_barcode ebook_id cyin profile affiliation faculty degree progtype year subject1 subject2).to_csv

CSV.foreach(old_csv_file, headers: :true, header_converters: :symbol) do |row|
  ebook_id = row[:ebook_id]
  if ebook_id.to_i.nonzero?
    # Then it's in the short form, like 37428, so we need to turn
    # it into the complete form.
    if id_map.include? ebook_id
      # It's already known.  Easy peasy lemon squeezy.
      row[:ebook_id] = id_map[ebook_id][:complete_id]
    else
      # It's not already known, so pick the information we need
      # out of the contents page.
      ebook_uri = "https://books.scholarsportal.info/viewdoc.html?id=#{ebook_id}"
      begin
        doc = Nokogiri::HTML(open(ebook_uri))
        ebook_title = doc.at_css("//head/title")
                        .text
                        .gsub(" - Scholars Portal Books", "")
        # The permalink on the page always points to the complete ID.
        ebook_permalink = doc.at_css("a[text()='Permalink']/@href").value
        permalink_params = CGI.parse(URI(ebook_permalink).query)
        complete_id = permalink_params["id"][0]
        # Add this to the ID map hash, which we'll write out later.
        id_map[ebook_id][:complete_id] = complete_id
        id_map[ebook_id][:title] = ebook_title
        id_map_changed = true
        row[:ebook_id] = complete_id
      rescue StandardError => e
        STDERR.puts "#{ebook_uri}: #{e}"
      end
    end
  end
  puts row.to_csv
end

# There must be a nice way to append as we go, but I couldn't figure it out.
# Brute force it and rewrite the whole thing when needed.
if id_map_changed
  CSV.open(id_map_file, "w",
           write_headers: :true,
           headers: %w(numeric_id complete_id title)) do |csv|
    id_map.each do |numeric_id, details|
      csv << [numeric_id, details[:complete_id], details[:title]]
    end
  end
end
