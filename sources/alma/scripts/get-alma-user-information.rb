#!/usr/bin/env ruby
# frozen_string_literal: true

# BUGS:
#
# If the columns are reordered in the report, then parsing them breaks, because
# this relies on "Column1" and "Column2" to hold particular data.
# It would be possible to fix this by looking up the column headings in the XML
# and matching them to whatever column they happen to be in.
# Or, just don't mess with the report.

warn "------"
warn "Started: #{Time.now}"

require "csv"
require "fileutils"
require "nokogiri"
require "open-uri"

if ENV["ALMA_API_KEY"]
  api_key = ENV["ALMA_API_KEY"]
else
  abort "No ALMA_API_KEY environment variable defined"
end

# For writing out the data, at the end.
alma_user_data = "#{ENV['DASHYUL_DATA']}/alma/users"
yyyymmdd = Date.today.strftime("%Y%m%d")
user_information_file = "#{alma_user_data}/user-information.csv"
user_information_dated_file = "#{alma_user_data}/user-information-#{yyyymmdd}.csv"

api_url = "https://api-ca.hosted.exlibrisgroup.com/almaws/v1/analytics/reports"

# Paths to the two reports that generate the data we want.
# Note: if you turn on "warn url_to_get" so you can see the URL and use
# curl to grab the data by hand, you'll need to replace the spaces
# with + or %20.
root_path = "/shared/York University 01OCUL_YOR/Reports/Patron Stats"
profile_path = "#{root_path}/Active Patrons and Groups (DashYUL)"
affiliation_path = "#{root_path}/Active Patrons and Stat Categories (DashYUL)"
# TODO: Include an image in the docs that shows the structure in the browser.

# How many records to get at a time.  Min 25, max 1000.
limit = 1000

# Hash to contain all the user information we're getting.
# We'll build this up as we go, from the two sources,
# then dump it out as a CSV file at the end.
users = Hash.new { |h, k| h[k] = {} } # A hash of hashes

# First, the "Active Patrons and Groups" report, which gives user_barcode, cyin and profile

url_base = "#{api_url}?apikey=#{api_key}&path=#{profile_path}"
url_to_get = url_base + "&limit=#{limit}"

we_are_done = false
resumption_token = false

$stderr.print "Profile data: "

until we_are_done

  # warn url_to_get

  $stderr.print "."
  doc = Nokogiri::XML(URI.open(url_to_get)).remove_namespaces!
  # TODO: Deal with the namespace properly.

  doc.css("/report/QueryResult/ResultXml/rowset/Row").each do |row|
    # puts row
    cyin = row.css("Column1").text
    user_barcode = row.css("Column2").text
    profile = row.css("Column3").text
    users[user_barcode]["cyin"] = cyin
    users[user_barcode]["profile"] = profile
  end

  we_are_done = doc.css("//IsFinished").text == "true"
  # We use the same token, over and over until it's done.
  resumption_token ||= doc.css("//ResumptionToken").text
  # warn "Token: #{resumption_token}"

  url_to_get = api_url + "?apikey=#{api_key}&token=#{resumption_token}"

  # sleep 1
end

# Next, the affiliation report, which gives user_barcode and affiliation.
# The mechanics of this are as above, but we're adding to the users
# hash that already exists.

url_base = "#{api_url}?apikey=#{api_key}&path=#{affiliation_path}"
url_to_get = url_base + "&limit=#{limit}"

# Reset for the second download.
we_are_done = false
resumption_token = false

$stderr.print "\nAffiliation data: "

until we_are_done

  # warn url_to_get

  $stderr.print "."
  doc = Nokogiri::XML(URI.open(url_to_get)).remove_namespaces!
  # TODO: Deal with the namespace properly.

  doc.css("/report/QueryResult/ResultXml/rowset/Row").each do |row|
    # puts row
    affiliation = row.css("Column1").text
    user_barcode = row.css("Column2").text
    users[user_barcode]["affiliation"] = affiliation
  end

  we_are_done = doc.css("//IsFinished").text == "true"
  # We use the same token, over and over until it's done.
  resumption_token ||= doc.css("//ResumptionToken").text
  # warn "Token: #{resumption_token}"

  url_to_get = api_url + "?apikey=#{api_key}&token=#{resumption_token}"

  # sleep 1
end

# Now write it all out.

File.open(user_information_dated_file, "w") do |file|
  file.write %w[user_barcode cyin profile affiliation].to_csv
  users.each do |barcode|
    file.write [barcode[0], barcode[1]["cyin"], barcode[1]["profile"], barcode[1]["affiliation"]].to_csv
  end
end

# FileUtils.rm user_information_file
FileUtils.symlink user_information_dated_file, user_information_file, force: true

warn "\nFinished: #{Time.now}"
