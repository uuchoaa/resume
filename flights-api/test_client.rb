#!/usr/bin/env ruby
# frozen_string_literal: true

# Manual integration test for Google Flights Client
# This is NOT part of the automated test suite
# Use this to manually test actual API calls with current tokens

require_relative 'GoogleFlightsClient'
require 'json'

puts "Google Flights Client - Manual Integration Test"
puts "=" * 60
puts "⚠️  Warning: This uses static tokens that may have expired"
puts "=" * 60
puts ""

client = GoogleFlightsClient.new

# Test with the same parameters we captured in HAR
puts "Testing search: GRU → REC (2025-12-10 to 2025-12-17)"
result = client.search(
  origin: 'GRU',
  destination: 'REC',
  departure_date: '2025-12-10',
  return_date: '2025-12-17'
)

puts "\nResult:"
puts "-" * 60

if result[:error]
  puts "❌ Error: #{result[:error]}"
  puts "Details: #{result[:details]}" if result[:details]
  
  if result[:raw_body_preview]
    puts "\nRaw body preview (first 500 chars):"
    puts result[:raw_body_preview][0..500]
  end
  
  puts "\n💡 Tip: Tokens may have expired. Extract new tokens from:"
  puts "   1. Open Google Flights in browser"
  puts "   2. Open DevTools → Network tab"
  puts "   3. Perform a search"
  puts "   4. Find GetShoppingResults request"
  puts "   5. Copy headers and update GoogleFlightsClient.rb"
else
  puts "✅ Status: #{result[:status]}"
  puts "Note: #{result[:note]}"

  if result[:best_flights]
    puts "\n✈️  Flights found: #{result[:best_flights].length}"
    
    result[:best_flights].first(3).each_with_index do |flight, idx|
      puts "\n--- Flight ##{idx + 1} ---"
      puts "#{flight[:airline]} (#{flight[:airline_code]}) - #{flight[:airplane]}"
      puts "#{flight[:departure_airport][:code]} → #{flight[:arrival_airport][:code]}"
      puts "Departure: #{flight[:departure_time]}"
      puts "Arrival: #{flight[:arrival_time]}"
      puts "Duration: #{flight[:duration]} minutes"
      puts "Stops: #{flight[:stops]}"
      puts "Price: R$ #{flight[:price]}"
    end
    
    if result[:best_flights].length > 3
      puts "\n... and #{result[:best_flights].length - 3} more flights"
    end

    # Save full response
    output_file = 'last_response.json'
    File.write(output_file, JSON.pretty_generate([result[:status], result[:best_flights], result]))
    puts "\n💾 Full response saved to: #{output_file}"
    puts "   File size: #{File.size(output_file) / 1024} KB"
  end
end

puts "\n" + "=" * 60
puts "Test completed!"
puts ""
puts "📝 Next steps:"
puts "   - Run automated tests: rake test"
puts "   - Run parser tests: rake test_parser"
puts "   - Run all tests: ruby test/test_all.rb"
