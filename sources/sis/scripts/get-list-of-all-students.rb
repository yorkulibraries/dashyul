#!/usr/bin/env ruby
# frozen_string_literal: true

# Get a big list of all enrolled students. We need this because we
# know students who logged in to EZProxy or borrowed an item, but we
# don't know the ones who didn't.

require "oci8"
require "csv"

# As long as the input_csv_file has a 'cyin' column, this script will
# work. That's all it cares about. It will print to STDOUT a CSV
# structure with detailed information about all the student CYINs in
# that file.

connection = OCI8.new(ENV["SIS_USERNAME"], ENV["SIS_PASSWORD"], ENV["SIS_TNS_HOSTNAME"])

# > desc VIEW_UIT_PASSPORTYORK;
# Name                       Null?    Type
# -------------------------- -------- -------------
# SISID                               NUMBER(9)
# SEQPERSPROG                         NUMBER
# ACADEMICYEAR                        CHAR(4)
# STUDYSESSION                        CHAR(2)
# PROGFACULTY                         CHAR(2)
# ACADQUALIFICATION                   CHAR(5)
# PROGID                              NUMBER(8)
# QUALSTREAM                          VARCHAR2(4)
# STUDYLEVEL                          VARCHAR2(2)
# YUARPROGTYPE                        CHAR(2)
# PROGTYPE                            VARCHAR2(1)
# SUBJECT1                            VARCHAR2(4)
# SUBJECT1ROLE                        VARCHAR2(10)
# SUBJECT2                            VARCHAR2(4)
# SUBJECT2ROLE                        VARCHAR2(10)

puts %w[cyin faculty degree progtype year subject1 subject2].to_csv

# To dump out everything (for testing)
# cursor = connection.exec('SELECT * from view_uit_passportyork ORDER BY STUDYSESSION')
# while r = cursor.fetch
#   puts r.join(',')
# end
# cursor.close

begin
  cursor = connection.exec("SELECT * from view_uit_passportyork ORDER BY STUDYSESSION")
  while r = cursor.fetch_hash()
    cyin     = r["SISID"]
    faculty  = r["PROGFACULTY"]
    degree   = r["ACADQUALIFICATION"].gsub(/\s*/, "")
    progtype = r["PROGTYPE"]
    year     = r["STUDYLEVEL"]
    subject1 = (r["SUBJECT1"] || "").gsub(/\s*/, "")
    subject2 = (r["SUBJECT2"] || "").gsub(/\s*/, "")
    puts [cyin, faculty, degree, progtype, year, subject1.chomp, subject2.chomp].to_csv
  end
  cursor.close
rescue StandardError => e
  warn "Error: #{e}: unknown"
end

connection.logoff
