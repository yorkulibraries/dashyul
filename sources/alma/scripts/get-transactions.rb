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

# This wrapper is needed to AND two filters.  If there's just one filter,
# it can stand alone.
filter_wrapper = <<~WRAPPER
  <sawx:expr xsi:type="sawx:logical" op="and"
    xmlns:saw="com.siebel.analytics.web/report/v1.1" xmlns:sawx="com.siebel.analytics.web/expression/v1.1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    ::START_DATE_XML::
    ::END_DATE_XML::
  </sawx:expr>
WRAPPER

# The basic filter for loan dates.  We'll make two version of this:
# one for start date, one for end date.
loan_date_filter = <<-END_DATE
  <sawx:expr xsi:type="sawx:comparison" op="::OPERATION::">
    <sawx:expr xsi:type="sawx:sqlExpression">"Loan Date"."Loan Date"</sawx:expr>
    <sawx:expr xsi:type="xsd:date">::DATE::</sawx:expr>
  </sawx:expr>
END_DATE

start_date = "2020-08-25"
end_date = "2020-08-31"

start_date_xml = loan_date_filter.gsub("::OPERATION::", "greaterOrEqual").gsub("::DATE::", start_date)
end_date_xml = loan_date_filter.gsub("::OPERATION::", "lessOrEqual").gsub("::DATE::", end_date)

# Stick these into the wrapper, so we end up with a chunk of XML with the two filters inside.
filter_xml = filter_wrapper.gsub("::START_DATE_XML::", start_date_xml).gsub("::END_DATE_XML::", end_date_xml)

filter_xml_enc = CGI.escape(filter_xml)

puts filter_xml
puts filter_xml_enc

# exit

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
root_path = "/shared/York University 01OCUL_YOR/Reports/DashYUL"

report_path = "#{root_path}/Test:+Transaction+Date+Range"

url_base = "#{api_url}?apikey=#{api_key}&path=#{report_path}&filter=#{filter_xml_enc}"
url_to_get = url_base + "&limit=#{limit}"

doc = Nokogiri::XML(URI.open(url_to_get)).remove_namespaces!

puts doc
