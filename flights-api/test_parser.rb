#!/usr/bin/env ruby
require 'json'
require_relative 'GoogleFlightsClient'

puts "Testing Flight Parser"
puts "=" * 50

# Read the saved response
response_data = JSON.parse(File.read('last_response.json'))

# Create client instance
client = GoogleFlightsClient.new

# Test the parser directly
result = client.send(:extract_flights, response_data)

puts "\nParsed #{result[:best_flights].length} flights:"
puts "\nFirst flight:"
puts JSON.pretty_generate(result[:best_flights].first) if result[:best_flights].any?

puts "\n" + "=" * 50
puts "Parser test completed!"
