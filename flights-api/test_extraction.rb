#!/usr/bin/env ruby
require 'json'
require_relative 'GoogleFlightsClient'

puts "Testing Flight Extraction"
puts "=" * 50

# Read the saved response (already the parsed array from last_response.json)
raw_data = JSON.parse(File.read('last_response.json'))

# Create client instance
client = GoogleFlightsClient.new

begin
  # Call extract_flights directly
  result = client.send(:extract_flights, raw_data)
  
  puts "\n✓ Parsed #{result[:best_flights].length} flights\n"
  
  # Show first 2 flights
  result[:best_flights].first(2).each_with_index do |flight, idx|
    puts "\n--- Flight ##{idx + 1} ---"
    puts "Airline: #{flight[:airline]} (#{flight[:airline_code]})"
    puts "Route: #{flight[:departure_airport][:code]} → #{flight[:arrival_airport][:code]}"
    puts "Duration: #{flight[:duration]} minutes"
    puts "Price: R$ #{flight[:price]}"
    puts "Stops: #{flight[:stops]}"
    puts "Airplane: #{flight[:airplane]}"
    puts "Extensions: #{flight[:extensions].join(', ')}" if flight[:extensions].any?
    puts "Departure: #{flight[:departure_time]}"
    puts "Arrival: #{flight[:arrival_time]}"
    if flight[:carbon_emissions]
      puts "Carbon: #{flight[:carbon_emissions][:this_flight]}g CO2"
    end
  end
  
  puts "\n" + "=" * 50
  puts "✓ Parser test completed successfully!"
  
rescue => e
  puts "\n✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end
