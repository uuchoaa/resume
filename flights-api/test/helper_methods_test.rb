require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../GoogleFlightsClient'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class HelperMethodsTest < Minitest::Test
  def setup
    @client = GoogleFlightsClient.new
  end

  # format_datetime tests
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

  def test_format_datetime_with_nil_time
    date = [2025, 12, 10]
    result = @client.send(:format_datetime, date, nil)
    assert_equal "2025-12-10T00:00:00-03:00", result
  end

  def test_format_datetime_with_single_digit_values
    date = [2025, 1, 5]
    time = [9, 5]
    
    result = @client.send(:format_datetime, date, time)
    assert_equal "2025-01-05T09:05:00-03:00", result
  end

  # extract_airplane tests
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

  def test_extract_airplane_with_short_segment
    segment = [nil] * 10
    result = @client.send(:extract_airplane, segment)
    assert_nil result
  end

  def test_extract_airplane_with_different_models
    aircraft_models = ["Boeing 737", "Airbus A321neo", "Embraer E195-E2"]
    
    aircraft_models.each do |model|
      segment = [nil] * 18
      segment[17] = model
      result = @client.send(:extract_airplane, segment)
      assert_equal model, result
    end
  end

  # extract_airport_name tests
  def test_extract_airport_name_from_index_4
    segment = [nil] * 6
    segment[4] = "Aeroporto Internacional de São Paulo"
    
    result = @client.send(:extract_airport_name, segment, "GRU")
    assert_equal "Aeroporto Internacional de São Paulo", result
  end

  def test_extract_airport_name_from_index_5
    segment = [nil] * 6
    segment[5] = "São Paulo International Airport"
    
    result = @client.send(:extract_airport_name, segment, "GRU")
    assert_equal "São Paulo International Airport", result
  end

  def test_extract_airport_name_fallback_to_code
    result = @client.send(:extract_airport_name, nil, "GRU")
    assert_equal "GRU", result
  end

  def test_extract_airport_name_with_empty_segment
    segment = []
    result = @client.send(:extract_airport_name, segment, "JFK")
    assert_equal "JFK", result
  end

  # extract_extensions tests
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

  def test_extract_extensions_with_both_power_and_wifi
    segment = [nil] * 12
    segment[11] = [nil, true, nil, nil, nil, nil, nil, nil, nil, nil, true, 3]
    
    extensions = @client.send(:extract_extensions, segment)
    assert_includes extensions, "In-seat power & USB outlets"
    assert_includes extensions, "Wi-Fi"
    assert_equal 2, extensions.select { |e| e.include?("power") || e.include?("Wi-Fi") }.length
  end

  def test_extract_extensions_with_legroom
    segment = [nil] * 14
    segment[11] = []
    segment[13] = "86 cm"
    
    extensions = @client.send(:extract_extensions, segment)
    assert extensions.any? { |ext| ext.include?("86 cm") }
    assert extensions.any? { |ext| ext.include?("legroom") }
  end

  def test_extract_extensions_with_nil_segment
    extensions = @client.send(:extract_extensions, nil)
    assert_equal [], extensions
  end

  def test_extract_extensions_with_no_amenities
    segment = [nil] * 14
    segment[11] = [nil, false, nil, nil, nil, nil, nil, nil, nil, nil, false, 3]
    
    extensions = @client.send(:extract_extensions, segment)
    # Should still be an array, just empty or minimal
    assert_kind_of Array, extensions
  end

  # extract_carbon_emissions tests
  def test_extract_carbon_emissions
    segment = [nil] * 30
    segment[29] = 173907
    
    result = @client.send(:extract_carbon_emissions, segment)
    assert_kind_of Hash, result
    assert_equal 173907, result[:this_flight]
    assert_equal 173907, result[:typical_for_this_route]
    assert_equal 0, result[:difference_percent]
  end

  def test_extract_carbon_emissions_with_nil_segment
    result = @client.send(:extract_carbon_emissions, nil)
    assert_nil result
  end

  def test_extract_carbon_emissions_with_no_data
    segment = [nil] * 30
    result = @client.send(:extract_carbon_emissions, segment)
    assert_nil result
  end

  # extract_segments tests
  def test_extract_segments_basic_structure
    segments_array = [
      [nil, nil, nil, "GRU", nil, nil, "REC", nil, [10, 30], nil, [12, 45], 135, nil, nil, nil, nil, nil, "Airbus A320", nil, [2025, 12, 10], [2025, 12, 10], nil, ["LA", "3382", nil, "LATAM"]]
    ]
    
    result = @client.send(:extract_segments, segments_array)
    assert_kind_of Array, result
    assert_equal 1, result.length
    
    segment = result.first
    assert_equal "GRU", segment[:departure_airport]
    assert_equal "REC", segment[:arrival_airport]
    assert_equal "LATAM", segment[:airline]
    assert_equal "LA3382", segment[:flight_number]
  end

  def test_extract_segments_filters_nil_entries
    segments_array = [
      nil,
      [nil, nil, nil, "GRU", nil, nil, "BSB"],
      nil,
      [nil, nil, nil, "BSB", nil, nil, "REC"]
    ]
    
    result = @client.send(:extract_segments, segments_array)
    assert_equal 2, result.length
  end

  def test_extract_segments_with_empty_array
    result = @client.send(:extract_segments, [])
    assert_equal [], result
  end
end
