#!/usr/bin/env ruby

require 'cgi'
require 'csv'
require 'date'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'uri'

puts ["ebook_id", "common_id", "title"].to_csv

CSV.foreach("sp-ebook-id-mapping.csv", {:headers => true, :header_converters => :symbol}) do |row|
  # row[:ebook_id] is the easy numeric ID
  # toc_uri = "http://books2.scholarsportal.info/viewdoc/toc.html?id=" + row[:ebook_id].to_s
  ebook_uri = "http://books2.scholarsportal.info/viewdoc.html?id=" + row[:ebook_id].to_s
  title = "(Unknown #{row[:ebook_id]})"
  begin
    # toc = JSON.parse(open(toc_uri).read)
    toc = Nokogiri::HTML(open(ebook_uri))
    title = toc.css('//title').text.gsub(' - Scholars Portal Books', '')
  # if toc["toc"] && toc["toc"]["title"]
  #   title = toc["toc"]["title"]
  # end
  rescue
    STDERR.puts "ERROR: #{row[:ebook_id]}"
  end
  puts [row[:ebook_id], row[:common_id], title].to_csv
end
