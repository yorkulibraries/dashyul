#!/usr/bin/env ruby
# frozen_string_literal: true

warn "------"
warn "Started: #{Time.now}"

require "cgi"
require "csv"
require "fileutils"
require "nokogiri"
require "open-uri"

# https://developers.exlibrisgroup.com/blog/working-with-analytics-rest-apis/

##
## Alma settings
##

if ENV["ALMA_API_KEY"]
  api_key = ENV["ALMA_API_KEY"]
else
  abort "No ALMA_API_KEY environment variable defined"
end

limit = 25

api_url = "https://api-ca.hosted.exlibrisgroup.com/almaws/v1/analytics/reports"

# Paths to the two reports that generate the data we want.
root_path = "/shared/York University 01OCUL_YOR/CDA/wdenton"

report_path = "#{root_path}/Catalogue dump"

url_base = "#{api_url}?apikey=#{api_key}&path=#{report_path}"
url_to_get = url_base + "&limit=#{limit}"

warn url_to_get
warn URI.parse(url_to_get)

doc = Nokogiri::XML(URI.parse(url_to_get).open).remove_namespaces!

puts doc
