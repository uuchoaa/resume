require 'minitest/autorun'
require 'minitest/reporters'
require 'json'
require_relative 'GoogleFlightsClient'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class GoogleFlightsClientTest < Minitest::Test
  def setup
    @client = GoogleFlightsClient.new
    @sample_response = JSON.parse(File.read('last_response.json'))
  end

  def test_client_initialization
    assert_instance_of GoogleFlightsClient, @client
  end

  def test_extract_flights_returns_hash
    result = @client.send(:extract_flights, @sample_response)
    assert_kind_of Hash, result
    assert result.key?(:best_flights)
  end

  def test_extract_flights_returns_array_of_flights
    result = @client.send(:extract_flights, @sample_response)
    assert_kind_of Array, result[:best_flights]
    assert result[:best_flights].length > 0, "Should extract at least one flight"
  end

  def test_flight_has_required_fields
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    required_fields = [
      :departure_airport, :arrival_airport, :duration, :airplane,
      :airline, :airline_code, :price, :departure_time, 
      :arrival_time, :stops, :segments
    ]

    required_fields.each do |field|
      assert flight.key?(field), "Flight should have #{field} field"
    end
  end

  def test_departure_airport_structure
    result = @client.send(:extract_flights, @sample_response)
    airport = result[:best_flights].first[:departure_airport]

    assert_kind_of Hash, airport
    assert airport.key?(:code)
    assert airport.key?(:name)
    assert_kind_of String, airport[:code]
    assert_kind_of String, airport[:name]
  end

  def test_arrival_airport_structure
    result = @client.send(:extract_flights, @sample_response)
    airport = result[:best_flights].first[:arrival_airport]

    assert_kind_of Hash, airport
    assert airport.key?(:code)
    assert airport.key?(:name)
  end

  def test_price_is_numeric
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    assert_kind_of Numeric, flight[:price]
    assert flight[:price] > 0, "Price should be positive"
  end

  def test_price_conversion_from_cents
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    # Price should be in BRL (reais), not cents
    # A typical flight costs hundreds/thousands of reais, not millions
    assert flight[:price] < 100000, "Price should be in BRL, not cents"
  end

  def test_duration_is_positive_integer
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    assert_kind_of Integer, flight[:duration]
    assert flight[:duration] > 0, "Duration should be positive"
  end

  def test_airline_fields
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    assert_kind_of String, flight[:airline]
    assert_kind_of String, flight[:airline_code]
    refute_empty flight[:airline]
    refute_empty flight[:airline_code]
  end

  def test_datetime_format
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    # Should be ISO 8601 format
    iso_regex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/
    
    if flight[:departure_time]
      assert_match iso_regex, flight[:departure_time]
    end
    
    if flight[:arrival_time]
      assert_match iso_regex, flight[:arrival_time]
    end
  end

  def test_segments_is_array
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    assert_kind_of Array, flight[:segments]
  end

  def test_segment_structure
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first
    
    return if flight[:segments].empty?
    
    segment = flight[:segments].first
    assert_kind_of Hash, segment
    
    segment_fields = [:departure_airport, :arrival_airport, :duration, :airline, :flight_number]
    segment_fields.each do |field|
      assert segment.key?(field), "Segment should have #{field} field"
    end
  end

  def test_extensions_is_array
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    assert_kind_of Array, flight[:extensions]
  end

  def test_stops_count
    result = @client.send(:extract_flights, @sample_response)
    flight = result[:best_flights].first

    assert_kind_of Integer, flight[:stops]
    assert flight[:stops] >= 0, "Stops should be non-negative"
  end

  def test_extract_flights_handles_nil_input
    result = @client.send(:extract_flights, nil)
    assert_equal({ best_flights: [] }, result)
  end

  def test_extract_flights_handles_empty_input
    result = @client.send(:extract_flights, [])
    assert_equal({ best_flights: [] }, result)
  end

  def test_format_datetime_with_array_time
    date = [2025, 12, 10]
    time = [23, 30]
    
    result = @client.send(:format_datetime, date, time)
    assert_equal "2025-12-10T23:30:00-03:00", result
  end

  def test_format_datetime_with_integer_time
    date = [2025, 12, 10]
    time = 14
    
    result = @client.send(:format_datetime, date, time)
    assert_equal "2025-12-10T14:00:00-03:00", result
  end

  def test_format_datetime_with_nil_date
    result = @client.send(:format_datetime, nil, [12, 30])
    assert_nil result
  end

  def test_format_datetime_with_incomplete_date
    result = @client.send(:format_datetime, [2025, 12], [12, 30])
    assert_nil result
  end

  def test_extract_airplane
    segment = [nil] * 18
    segment[17] = "Airbus A320"
    
    result = @client.send(:extract_airplane, segment)
    assert_equal "Airbus A320", result
  end

  def test_extract_airplane_with_nil_segment
    result = @client.send(:extract_airplane, nil)
    assert_nil result
  end

  def test_extract_airport_name
    segment = [nil] * 6
    segment[4] = "Test Airport Name"
    
    result = @client.send(:extract_airport_name, segment, "TST")
    assert_equal "Test Airport Name", result
  end

  def test_extract_airport_name_fallback
    result = @client.send(:extract_airport_name, nil, "GRU")
    assert_equal "GRU", result
  end

  def test_extract_extensions_with_power
    segment = [nil] * 12
    segment[11] = [nil, true, nil, nil, nil, nil, nil, nil, nil, nil, false, 3]
    
    extensions = @client.send(:extract_extensions, segment)
    assert_includes extensions, "In-seat power & USB outlets"
  end

  def test_extract_extensions_with_wifi
    segment = [nil] * 12
    segment[11] = [nil, false, nil, nil, nil, nil, nil, nil, nil, nil, true, 3]
    
    extensions = @client.send(:extract_extensions, segment)
    assert_includes extensions, "Wi-Fi"
  end

  def test_extract_extensions_with_legroom
    segment = [nil] * 14
    segment[13] = "86 cm"
    
    extensions = @client.send(:extract_extensions, segment)
    assert extensions.any? { |ext| ext.include?("86 cm") }
  end

  def test_multiple_flights_extracted
    result = @client.send(:extract_flights, @sample_response)
    
    # We know the sample response has multiple flights
    assert result[:best_flights].length >= 2, "Should extract multiple flights from sample data"
  end

  def test_flights_have_different_prices
    result = @client.send(:extract_flights, @sample_response)
    
    return if result[:best_flights].length < 2
    
    prices = result[:best_flights].map { |f| f[:price] }.compact.uniq
    assert prices.length > 1, "Different flights should have different prices"
  end

  def test_airline_codes_are_valid
    result = @client.send(:extract_flights, @sample_response)
    
    result[:best_flights].each do |flight|
      # Airline codes are typically 2 characters (LA, AD, etc.)
      assert flight[:airline_code].length >= 2, "Airline code should be at least 2 characters"
      assert flight[:airline_code].match?(/^[A-Z0-9]+$/), "Airline code should be alphanumeric uppercase"
    end
  end

  def test_airport_codes_are_three_letters
    result = @client.send(:extract_flights, @sample_response)
    
    result[:best_flights].each do |flight|
      dep_code = flight[:departure_airport][:code]
      arr_code = flight[:arrival_airport][:code]
      
      next unless dep_code && arr_code # Skip if codes are missing
      
      assert_equal 3, dep_code.length, "Departure airport code should be 3 letters"
      assert_equal 3, arr_code.length, "Arrival airport code should be 3 letters"
      assert dep_code.match?(/^[A-Z]+$/), "Airport codes should be uppercase letters"
      assert arr_code.match?(/^[A-Z]+$/), "Airport codes should be uppercase letters"
    end
  end
end
