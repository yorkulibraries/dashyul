#!/usr/bin/env ruby
# frozen_string_literal: true

warn "------"
warn "Started: #{Time.now}"

require "csv"
require "fileutils"
require "nokogiri"
require "open-uri"

##
## Alma settings
##

if ENV["ALMA_API_KEY"]
  api_key = ENV["ALMA_API_KEY"]
else
  abort "No ALMA_API_KEY environment variable defined"
end

api_url = "https://api-ca.hosted.exlibrisgroup.com/almaws/v1/analytics/reports"

# Paths to the two reports that generate the data we want.
root_path = "/shared/York University 01OCUL_YOR/Reports/DashYUL 2"

# "Profile" information.
# This report gives:
# Primary Identifier: user_barcode
# Identifier Value: CYIN
# User Group Code: profile (as we used to call it)
profile_path = "#{root_path}/Active+Patrons+and+Groups+with+Expiry+Dates"

# "Affiliation" information.
# This report gives:
# Primary Identifier: (user_barcode)
# Statistical Category: affiliation (as we used to call it)
affiliation_path = "#{root_path}/Active+Patrons+and+Stat+Categories"

# TODO: Include an image in the docs that shows the structure in the browser.

# How many records to get at a time.  Min 25, max 1000.
limit = 1000

##
## Local settings
##

# For writing out the data, at the end.
alma_user_data = "#{ENV['DASHYUL_DATA']}/alma/users"
yyyymmdd = Date.today.strftime("%Y%m%d")
user_information_file = "#{alma_user_data}/user-information-plus.csv"
user_information_dated_file = "#{alma_user_data}/user-information-plus-#{yyyymmdd}.csv"

##
## Parsing the Alma XML
##
def get_column_headings(alma_xml)
  # TODO: Add docs
  column_names = {}
  alma_xml.xpath("/report/QueryResult/ResultXml/rowset/schema/complexType/sequence/element").each do |v|
    column_names[v["name"].to_s] = v["columnHeading"].to_s
  end
  # warn column_names
  column_names
end

##
## Get the data!
##

# Hash to contain all the user information we're getting.
# We'll build this up as we go, from the two sources,
# then dump it out as a CSV file at the end.
users = Hash.new { |h, k| h[k] = {} } # A hash of hashes

# First, the "Active Patrons and Groups" report

url_base = "#{api_url}?apikey=#{api_key}&path=#{profile_path}"
url_to_get = url_base + "&limit=#{limit}"

we_are_done = false
header_processed = false
resumption_token = false
column_names = {}
$stderr.print "Profile data: "

until we_are_done

  # warn url_to_get

  $stderr.print "."
  doc = Nokogiri::XML(URI.open(url_to_get)).remove_namespaces!
  # TODO: Deal with the namespace properly.

  unless header_processed
    header_processed = true
    resumption_token = doc.at_xpath("//ResumptionToken").text
    # warn "Token: #{resumption_token}"

    column_names = get_column_headings(doc)
  end

  doc.xpath("/report/QueryResult/ResultXml/rowset/Row").each do |row|
    user_info = {}
    column_names.each_pair do |col, name|
      next if name == "0" # We don't need this one; I don't know why it's always there

      user_info[name] = row.xpath(col).text
    end

    users[user_info["Primary Identifier"]][:cyin] = user_info["Identifier Value"]
    users[user_info["Primary Identifier"]][:profile] = user_info["User Group Code"]
    users[user_info["Primary Identifier"]][:expiry_date] = user_info["Expiry Date"]
  end

  we_are_done = doc.at_xpath("//IsFinished").text == "true"

  url_to_get = api_url + "?apikey=#{api_key}&token=#{resumption_token}"

  # sleep 1
end

# Next, the affiliation report.
# The mechanics of this are as above, but we're adding to the users
# hash that already exists.

url_base = "#{api_url}?apikey=#{api_key}&path=#{affiliation_path}"
url_to_get = url_base + "&limit=#{limit}"

# Reset for the second download.
we_are_done = false
header_processed = false
resumption_token = false

$stderr.print "\nAffiliation data: "

until we_are_done

  # warn url_to_get

  $stderr.print "."
  doc = Nokogiri::XML(URI.open(url_to_get)).remove_namespaces!
  # TODO: Deal with the namespace properly.

  unless header_processed
    header_processed = true
    resumption_token = doc.at_xpath("//ResumptionToken").text
    # warn "Token: #{resumption_token}"

    column_names = get_column_headings(doc)
  end

  doc.xpath("/report/QueryResult/ResultXml/rowset/Row").each do |row|
    user_info = {}
    column_names.each_pair do |col, name|
      next if name == "0" # We don't need this one; I don't know why it's always there

      user_info[name] = row.xpath(col).text
    end
    users[user_info["Primary Identifier"]][:affiliation] = user_info["Statistical Category"].gsub("None", "")
    # puts user_info
  end

  we_are_done = doc.css("//IsFinished").text == "true"
  # We use the same token, over and over until it's done.

  url_to_get = api_url + "?apikey=#{api_key}&token=#{resumption_token}"

  # sleep 1
end

# Now write it all out.

File.open(user_information_dated_file, "w") do |file|
  file.write %w[user_barcode cyin profile affiliation].to_csv
  users.each_pair do |barcode, data|
    file.write [barcode, data[:cyin], data[:profile], data[:affiliation], data[:expiry_date]].to_csv
  end
end

FileUtils.symlink user_information_dated_file, user_information_file, force: true

warn "\nFinished: #{Time.now}"
