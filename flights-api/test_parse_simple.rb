#!/usr/bin/env ruby
require 'json'

puts "Step-by-step parser test"
puts "=" * 50

# Step 1: Load data
data = JSON.parse(File.read('last_response.json'))
puts "✓ Loaded data"

# Step 2: Parse inner JSON
inner_data = JSON.parse(data[0][2])
puts "✓ Parsed inner JSON, length: #{inner_data.length}"

# Step 3: Get flights array
flights_array = inner_data[2] || []
puts "✓ Found flights array, length: #{flights_array.length}"

# Step 4: Process first flight
if flights_array[0] && flights_array[0][0]
  flight_data = flights_array[0][0]
  flight_info = flight_data[0]
  
  if flight_info
    puts "\n✓ First flight info:"
    puts "  - Airline code: #{flight_info[0]}"
    puts "  - Airline names: #{flight_info[1].inspect}"
    puts "  - Segments: #{flight_info[2].length rescue 'N/A'}"
    puts "  - Departure: #{flight_info[3]}"
    puts "  - Arrival: #{flight_info[6]}"
    puts "  - Duration: #{flight_info[9]} minutes"
    
    # Price
    price_data = flight_data[9]
    if price_data && price_data[7]
      puts "  - Price: R$ #{(price_data[7] / 100.0).round(2)}"
    else
      puts "  - Price: N/A (price_data: #{price_data.inspect})"
    end
  else
    puts "✗ flight_info is nil"
  end
else
  puts "✗ No flight data found"
end

puts "\n" + "=" * 50
puts "Test completed!"
