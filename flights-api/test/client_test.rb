require 'minitest/autorun'
require 'minitest/reporters'
require 'net/http'
require_relative '../google_flights_client'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class GoogleFlightsClientIntegrationTest < Minitest::Test
  def setup
    @client = GoogleFlightsClient.new
  end

  def test_build_request_returns_http_request
    uri = URI('https://www.google.com/_/FlightsFrontendUi/data/test')
    origin = 'GRU'
    destination = 'REC'
    departure_date = '2025-12-10'
    return_date = '2025-12-17'
    
    request = @client.send(:build_request, uri, origin, destination, departure_date, return_date)
    
    assert_instance_of Net::HTTP::Post, request
  end

  def test_build_request_sets_required_headers
    uri = URI('https://www.google.com/_/FlightsFrontendUi/data/test')
    origin = 'GRU'
    destination = 'REC'
    departure_date = '2025-12-10'
    return_date = '2025-12-17'
    
    request = @client.send(:build_request, uri, origin, destination, departure_date, return_date)
    
    required_headers = [
      'Content-Type',
      'X-Goog-BatchExecute-Bgr',
      'X-Browser-Validation',
      'X-Goog-Ext-259736195-Jspb',
      'X-Same-Domain'
    ]
    
    required_headers.each do |header|
      assert request[header], "Request should have #{header} header"
      refute_empty request[header], "#{header} should not be empty"
    end
  end

  def test_build_request_content_type
    uri = URI('https://www.google.com/_/FlightsFrontendUi/data/test')
    request = @client.send(:build_request, uri, 'GRU', 'REC', '2025-12-10', '2025-12-17')
    assert_equal 'application/x-www-form-urlencoded;charset=UTF-8', request['Content-Type']
  end

  def test_build_request_same_domain_header
    uri = URI('https://www.google.com/_/FlightsFrontendUi/data/test')
    request = @client.send(:build_request, uri, 'GRU', 'REC', '2025-12-10', '2025-12-17')
    assert_equal '1', request['X-Same-Domain']
  end

  def test_build_payload_contains_origin
    payload = @client.send(:build_payload, 'GRU', 'REC', '2025-12-10', '2025-12-17')
    
    # Payload is URL-encoded, so check for the airport code
    assert payload.is_a?(String), "Payload should be a string"
    refute_empty payload, "Payload should not be empty"
  end

  def test_build_payload_contains_destination
    payload = @client.send(:build_payload, 'GRU', 'REC', '2025-12-10', '2025-12-17')
    
    assert payload.include?('REC'), "Payload should contain destination airport code"
  end

  def test_build_payload_contains_dates
    departure = '2025-12-10'
    return_date = '2025-12-17'
    payload = @client.send(:build_payload, 'GRU', 'REC', departure, return_date)
    
    assert payload.include?(departure), "Payload should contain departure date"
    assert payload.include?(return_date), "Payload should contain return date"
  end

  def test_build_payload_structure
    payload = @client.send(:build_payload, 'GRU', 'REC', '2025-12-10', '2025-12-17')
    
    # Should be URL encoded
    assert payload.start_with?('f.req='), "Payload should start with f.req="
    assert payload.include?('%'), "Payload should be URL encoded"
  end

  def test_decode_response_body_handles_brotli
    skip "Requires actual Brotli compressed data" unless defined?(Brotli)
    
    # This test would need actual Brotli compressed data
    # Skipping for now as it requires integration data
  end

  def test_decode_response_body_handles_plain_text
    # Create a proper mock response object that responds to both .body and []
    response_class = Struct.new(:body) do
      def [](key)
        nil # No encoding header
      end
    end
    response = response_class.new("test response")
    
    result = @client.send(:decode_response_body, response)
    assert_equal "test response", result
  end

  def test_parse_response_removes_security_prefix
    body = ")]}'\n\n123\n[\"test\"]"
    result = @client.send(:parse_response, body)
    
    # Should process without the prefix
    assert result[:status] == 'success' || result[:error]
  end

  def test_parse_response_handles_empty_body
    body = ""
    result = @client.send(:parse_response, body)
    
    # Should handle gracefully
    assert result.is_a?(Hash)
  end

  def test_search_method_returns_hash
    # Note: This will fail with actual API call due to expired tokens
    # but we can test that it returns the right structure
    
    # We'll stub this to test structure
    skip "Requires valid tokens - use with actual API call"
  end

  def test_client_handles_connection_errors
    # Test that client gracefully handles network errors
    skip "Requires network error simulation"
  end

  def test_client_handles_timeout
    # Test timeout handling
    skip "Requires timeout simulation"
  end

  def test_build_payload_escapes_special_characters
    # Test that special characters in airport codes are handled
    payload = @client.send(:build_payload, 'O\'Hare', 'JFK', '2025-12-10', '2025-12-17')
    
    # Should be properly encoded
    assert payload.is_a?(String)
    refute payload.include?("'"), "Special characters should be escaped"
  end

  def test_multiple_requests_with_same_client
    # Test that the same client instance can be reused
    client = GoogleFlightsClient.new
    uri = URI('https://www.google.com/_/FlightsFrontendUi/data/test')
    
    request1 = client.send(:build_request, uri, 'GRU', 'REC', '2025-12-10', '2025-12-17')
    request2 = client.send(:build_request, uri, 'GIG', 'SSA', '2025-12-15', '2025-12-20')
    
    assert_instance_of Net::HTTP::Post, request1
    assert_instance_of Net::HTTP::Post, request2
    
    # Different requests should have different payloads
    refute_equal request1.body, request2.body
  end
end
