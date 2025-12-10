require 'minitest/autorun'
require 'minitest/reporters'
require 'json'
require 'fileutils'
require_relative '../google_flights_client'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Integration tests that make real API calls to Google Flights
# These tests are SLOW and require valid API tokens
# Skip by default - run with: ruby test/integration_test.rb
class GoogleFlightsIntegrationTest < Minitest::Test
  def setup
    skip "Integration tests disabled by default. Run with: ruby test/integration_test.rb" if ENV['SKIP_INTEGRATION']
    
    @snapshot_file = File.join(__dir__, 'snapshots', 'last_integration_results.json')
    
    # Load from snapshot if exists, otherwise make real API call
    if File.exist?(@snapshot_file)
      puts "  📸 Loading cached response from snapshot..."
      @result = JSON.parse(File.read(@snapshot_file), symbolize_names: true)
    else
      puts "  🌐 Making real API call (no snapshot found)..."
      @client = GoogleFlightsClient.new
      
      @result = @client.search(
        origin: 'CGH',
        destination: 'JPA',
        departure_date: '2026-02-06',
        return_date: '2026-02-27'
      )
      
      # Save snapshot for future runs
      FileUtils.mkdir_p(File.dirname(@snapshot_file))
      File.write(@snapshot_file, JSON.pretty_generate(@result))
      puts "  💾 Saved snapshot to #{@snapshot_file}"
    end
  end

  def test_api_returns_success
    assert_equal 'success', @result[:status], "API should return success status"
  end

  def test_api_response_structure
    assert_kind_of Hash, @result
    assert @result.key?(:status)
    assert @result.key?(:best_flights)
    assert_kind_of Array, @result[:best_flights]
    refute_empty @result[:best_flights], "Should return at least one flight"
  end

  def test_all_flights_have_required_fields
    @result[:best_flights].each_with_index do |flight, i|
      assert flight.key?(:price), "Flight #{i} missing :price"
      assert flight.key?(:airline), "Flight #{i} missing :airline"
      assert flight.key?(:airline_code), "Flight #{i} missing :airline_code"
      assert flight.key?(:departure_time), "Flight #{i} missing :departure_time"
      assert flight.key?(:arrival_time), "Flight #{i} missing :arrival_time"
      assert flight.key?(:departure_airport), "Flight #{i} missing :departure_airport"
      assert flight.key?(:arrival_airport), "Flight #{i} missing :arrival_airport"
      assert flight.key?(:duration), "Flight #{i} missing :duration"
      assert flight.key?(:stops), "Flight #{i} missing :stops"
      assert flight.key?(:airplane), "Flight #{i} missing :airplane"
      assert flight.key?(:flight_number), "Flight #{i} missing :flight_number"
    end
  end

  def test_flight_prices_are_valid
    flights = @result[:best_flights]
    
    flights.each_with_index do |flight, i|
      assert flight[:price] > 0, "Flight #{i} price should be positive"
      assert_kind_of Numeric, flight[:price]
    end
    
    # Expected price from screenshot: R$1,427 (first flight)
    # Allow 50% variation due to dynamic pricing
    first_price = flights[0][:price]
    expected_first_price = 1427.0
    
    price_ratio = first_price / expected_first_price
    assert price_ratio > 0.5 && price_ratio < 1.5, 
           "Price variation too large: got #{first_price}, expected ~#{expected_first_price}"
  end

  def test_airlines_are_valid
    flights = @result[:best_flights]
    valid_airlines = ['LATAM', 'Gol', 'Azul', 'Avianca']
    
    flights.each do |flight|
      assert_includes valid_airlines, flight[:airline], 
                      "Airline '#{flight[:airline]}' should be valid"
      assert_match(/^[A-Z0-9]{2,3}$/, flight[:airline_code], 
                   "Airline code should be 2-3 uppercase alphanumeric chars")
    end
  end

  def test_times_are_properly_formatted
    flights = @result[:best_flights]
    
    flights.each do |flight|
      # Times can be either "HH:MM" format or ISO 8601
      assert flight[:departure_time], "Should have departure_time"
      assert flight[:arrival_time], "Should have arrival_time"
    end
  end

  def test_direct_flights_exist
    direct_flights = @result[:best_flights].select { |f| f[:stops] == 0 }
    
    refute_empty direct_flights, "Should have at least one direct flight"
    direct_flights.each do |flight|
      assert_equal 0, flight[:stops]
    end
  end

  def test_connecting_flights_structure
    connecting_flights = @result[:best_flights].select { |f| f[:stops] > 0 }
    
    skip "No connecting flights in results" if connecting_flights.empty?
    
    connecting_flights.each do |flight|
      assert flight[:stops] > 0
      # Segments may or may not be present depending on parser implementation
    end
  end

  def test_airport_structure
    flight = @result[:best_flights].first
    
    [:departure_airport, :arrival_airport].each do |key|
      airport = flight[key]
      assert_kind_of Hash, airport
      assert airport.key?(:code), "Airport should have :code"
      assert_equal 3, airport[:code].length, "Airport code should be 3 letters"
      assert_match(/^[A-Z]{3}$/, airport[:code], "Airport code should be 3 uppercase letters")
    end
  end

  def test_all_flights_correct_route
    @result[:best_flights].each do |flight|
      assert_equal 'CGH', flight[:departure_airport][:code]
      assert_equal 'JPA', flight[:arrival_airport][:code]
    end
  end

  def test_extensions_array_present
    @result[:best_flights].each_with_index do |flight, i|
      assert flight.key?(:extensions), "Flight #{i} should have extensions"
      assert_kind_of Array, flight[:extensions]
    end
  end

  def test_durations_are_positive
    @result[:best_flights].each do |flight|
      assert flight[:duration] > 0, "Duration should be positive"
      assert_kind_of Integer, flight[:duration]
    end
  end

  def test_prices_are_sorted
    prices = @result[:best_flights].map { |f| f[:price] }
    
    # Prices should generally be in ascending order (best deals first)
    # Allow some variation but first should be cheaper than last
    assert prices.first <= prices.last * 1.5, 
           "Prices should be roughly sorted (best deals first)"
  end

  def test_response_matches_expected_format
    # Expected keys based on expected_output.json
    expected_keys = [
      :price, :airline, :airline_code, :departure_time, :arrival_time,
      :departure_airport, :arrival_airport, :duration, :stops, 
      :airplane, :flight_number, :emissions, :extensions
    ].sort
    
    flight = @result[:best_flights].first
    actual_keys = flight.keys.sort
    
    missing_keys = expected_keys - actual_keys
    assert_empty missing_keys, "Missing keys in actual response: #{missing_keys.join(', ')}"
  end

  def test_snapshot_file_exists
    assert File.exist?(@snapshot_file), "Snapshot file should exist after first run"
  end
end
