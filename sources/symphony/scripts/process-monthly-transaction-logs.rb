#!/usr/bin/env ruby

# Parse Symphony transaction logs to pick out the data I need and save
# it in a tidy CSV file.

# TODO:  Strip final ^Q this before splitting the line

require "csv"

require_relative "command-codes"
require_relative "data-codes"

error_lines = []

puts %w[date
        transaction_command
        library
        item_barcode
        user_barcode].to_csv

ARGF.each do |line|
  begin
    # Change character encoding to UTF-8, and throw out anything that
    # doesn't make it.  We won't need it.
    line.encode!("UTF-8", "ISO-8859-1", invalid: :replace)

    parse_line = /([[:alpha:]][[:digit:]]+[[:alpha:]]) (.*)/.match(line)

    stamp = parse_line[1]
    # Just use the date, who cares about the time of day?
    # If we ever do, reprocess.
    transaction_date = Time.local(stamp[1..4], stamp[5..6], stamp[7..8]).to_date

    codes = parse_line[2]
    parse_codes = codes.split(/\^/)

    # transaction_index will match # ^S01, ^S76, etc.
    transaction_index = parse_codes.find_index { |c| /^S\d{2}/.match(c) }
    transaction = parse_codes[transaction_index]
    parse_codes.delete_at(transaction_index)

    # We only want these four transaction commands: CV, EV, RV or JZ
    # Ignore everything else.
    transaction_command = transaction[3..4]
    # next unless /(CV|EV|JZ|RV)/.match(transaction_command)
    next unless transaction_command =~ /(CV|EV|JZ|RV)/

    transaction_string = transaction[5..-1]
    transaction_string.gsub(/\^O$/, "") # Delete ^O line terminator

    transaction_data = {}
    parse_codes.each do |code|
      data_command = code[0..1]
      data_string = code[2..-1]
      next if data_command.empty?
      transaction_data[data_command] = data_string
    end

    puts [transaction_date,
          transaction_command,
          transaction_data["FE"],
          transaction_data["NQ"],
          transaction_data["UO"]].to_csv
  rescue StandardError # => e
    error_lines << line
  end
end

error_lines.each do |e|
  STDERR.puts e
end

STDERR.puts "Failed transactions: #{error_lines.size}"
