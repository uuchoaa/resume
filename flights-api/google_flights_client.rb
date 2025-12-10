require 'net/http'
require 'uri'
require 'json'

class GoogleFlightsClient
  ENDPOINT = 'https://www.google.com/_/FlightsFrontendUi/data/travel.frontend.flights.FlightsFrontendService/GetShoppingResults'

  def initialize
    # Using static values from captured HAR file
  end

  def search(origin:, destination:, departure_date:, return_date:)
    uri = build_uri
    request = build_request(uri, origin, destination, departure_date, return_date)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Handle different response scenarios
    case response
    when Net::HTTPSuccess
      body = decode_response_body(response)
      parse_response(body)
    else
      {
        error: "HTTP #{response.code}",
        message: response.message,
        body: response.body[0..1000]
      }
    end
  rescue => e
    { error: e.message, details: e.backtrace.first(5) }
  end

  private

  def build_uri
    URI.parse("#{ENDPOINT}?#{query_params}")
  end

  def query_params
    # Static values from HAR - will need to be updated over time
    "f.sid=8222137087800291779&bl=boq_travel-frontend-flights-ui_20251208.02_p0&hl=pt-BR&soc-app=162&soc-platform=1&soc-device=1&_reqid=980646&rt=c"
  end

  def build_request(uri, origin, destination, departure_date, return_date)
    request = Net::HTTP::Post.new(uri)

    # Headers from HAR file
    request['Accept'] = '*/*'
    request['Accept-Encoding'] = 'gzip, deflate, br, zstd'
    request['Accept-Language'] = 'pt-BR,pt;q=0.9'
    request['Cache-Control'] = 'no-cache'
    request['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
    request['Origin'] = 'https://www.google.com'
    request['Pragma'] = 'no-cache'
    request['Referer'] = 'https://www.google.com/travel/flights'
    request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'

    # Critical anti-bot headers (static from HAR - may expire)
    request['X-Browser-Validation'] = 'AUXUCdutEJ+6gl6bYtz7E2kgIT4='
    request['X-Goog-Ext-259736195-Jspb'] = '["pt-BR","BR","BRL",1,null,[180],null,null,7,[]]'
    request['X-Same-Domain'] = '1'

    # This massive token may need to be refreshed periodically
    request['X-Goog-BatchExecute-Bgr'] = '[";8e-477fQAAZyDDXqUgxfzQ5Cw90raa4mADQBEArZ1MxqRSw6coJDge8DUQvQzgYbpnyPW0x0gJ-0ud3VqLsyvndsGv3Tw52iMrBkoIqNHwAAAC9PAAAAAnUBB2MAQ0vkCCjEm9SbwsECLsDwoGFKIxr7NobQS38ojY7SScZ1jNzW0cHQpdJUZ_ISv70Lg1rEPmlOfsto1setDCVvEbEQwUiEA17F82oewOe81buxN-RCiJGncUH7aI9NtnMbm_L0PZaaQiFe3s__e19JhkS9VVBH2RJDMFpMmaViwISA81H-QKqb-4t8Yis7_zv8uQtR5giXrwuBiQgqDSQjZgbnobOW3W2lJPsPPyIiSZkxLGmCZdpXA0XlmOCMLkeO4Owdserl_NRxuZW5slRQ_OFuCiw0iJOmEzrW0dIAX3YDmFZgJlH3ErKQJV2UxulQ-lSMUouCeCsjlzCgKGm8oZ0tBDsvz-_Rgp3LAlIuJlDcb9Pg0bGpH0jmsg4Lz2AcQk4UtQbvt3kjVpaSRpynn0gueRHEn0B-sFIm1qCvKfYJC07PJX3z316uWOGbPsWwCARzylM8J36sZwvL8oRUBTlLdR5tLLcqEPN4_n9iK8qp0bPsM_sQmntwiNxbWsPMOFciBSW40CFSyop3N1hn_Qa3nIFNgSHQ095w6lTK7nhtKS-Pj4Y0BAUmVHFXYIkW0HSuI19zTEIm-BHDdxk88HIARpHGhEALQ2sSxqVx9HySrJ80I-Y1LjHYSc1Yntgoef9v1aGT4lRsxDTFDWjkhj-PBhw6L8T5iLqiiUYKh2xMfZIC3BTwWMTprxtQKfy4m95g3PnbIpTC0XTS33OuQAPnJ1IXjpgZaHVjQ0DTloVCCxfttpEzeysDQCANU203RbFhnE1o2XLnbwyT98NsVI0DX7bmaLVYe4IaSiDKlPnCC9LUYI-T0usZCdX0lfYiPPrmW0AxWC3jHMDN685o5YDBO5zTg6If8enCnpZdWLieAChYc0Ezzxwo6cFveQ70CwTt_pLBLDBlCWaS3y2hEKL2RquJkOTT81kcHkQgAMZIw3GcQoH2AdznytPAZd92R0V9r69hgDeF3f0atTAkYdPAfCmEnpcT7swsnmPeoXlQgMg_Vma1oH6DKw3RmcBAZXEbXAyfaCmKlagcUvqxEkSe2UuHhWvtfVpYP3dw3cajGxfYrUgPNbzECm4NLVSitWF1eHL6AcV_HpNpqCCL6DO7Zkl4ue-qk_OsEVRsgq1F860NruxzsJuVPYhdxZCeIzPeljH7DRfQvTnP3Pl-BgIVYNPdl6oJRkJD1zxtliKntd_-JVr_r97BNvsoAhrZAkBVHUHTKa69_yVnGbi30p_JX4zM",null,null,9,null,null,null,0,"5"]'

    # Build the payload
    request.body = build_payload(origin, destination, departure_date, return_date)

    request
  end

  def build_payload(origin, destination, departure_date, return_date)
    # Building the request payload structure
    # Format: f.req=[null,"[[],[ flight search params ],0,0,0,1]"]
    
    # Inner search parameters as nested arrays
    search_params = [
      [],
      [
        nil,
        nil,
        1,
        nil,
        [],
        1,
        [1, 0, 0, 0],
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        [
          # Outbound leg
          [
            [[[origin_code(origin), 4]]],
            [[[destination_code(destination), 0]]],
            nil,
            0,
            nil,
            nil,
            departure_date,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            3
          ],
          # Return leg
          [
            [[[destination_code(destination), 0]]],
            [[[origin_code(origin), 4]]],
            nil,
            0,
            nil,
            nil,
            return_date,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            3
          ]
        ],
        nil,
        nil,
        nil,
        1
      ],
      0,
      0,
      0,
      1
    ]

    # The payload is [null, "stringified_array"]
    payload = [nil, search_params.to_json]

    "f.req=#{URI.encode_www_form_component(payload.to_json)}&"
  end

  def origin_code(origin)
    # Map common airports to Google's internal codes
    # For cities, Google uses /m/ codes (from Wikidata/Freebase)
    # For airports, it uses IATA codes with type 0
    case origin.upcase
    when 'GRU', 'SAO', 'CGH', 'VCP'
      '/m/022pfm' # São Paulo city code
    else
      origin.upcase
    end
  end

  def destination_code(destination)
    destination.upcase
  end

  def decode_response_body(response)
    require 'zlib'
    require 'stringio'

    body = response.body
    encoding = response['content-encoding']

    case encoding
    when 'br'
      # Brotli compression - need brotli gem
      begin
        require 'brotli'
        body = Brotli.inflate(body)
      rescue LoadError
        raise "Brotli gem required. Install with: gem install brotli"
      end
    when 'gzip'
      # Gzip compression
      gz = Zlib::GzipReader.new(StringIO.new(body))
      body = gz.read
      gz.close
    end

    body
  end

  def parse_response(body)
    # Remove the security prefix: )]}'
    clean_body = body.gsub(/^\)\]\}'\n\n/, '')

    # The response contains multiple JSON objects separated by newlines
    # Format: number\n[json]\nnumber\n[json]...
    # We want the largest JSON object which contains the flight data

    json_objects = []
    lines = clean_body.lines

    i = 0
    while i < lines.length
      line = lines[i].strip

      # Skip empty lines and numbers
      if line.empty? || line.match?(/^\d+$/)
        i += 1
        next
      end

      # Try to parse as JSON
      begin
        obj = JSON.parse(line)
        json_objects << obj
      rescue JSON::ParserError
        # Skip invalid lines
      end

      i += 1
    end

    # Find the object with flight data (usually the largest one)
    raw_data = json_objects.max_by { |obj| obj.to_s.length }

    # Extract and structure the flight data
    structured_data = extract_flights(raw_data)

    {
      status: 'success',
      **structured_data,
      note: 'Successfully retrieved and parsed flight data from Google Flights'
    }
  rescue => e
    {
      error: 'Failed to parse response',
      details: e.message,
      backtrace: e.backtrace.first(3),
      raw_body_preview: body.force_encoding('UTF-8')[0..1000]
    }
  end

  def extract_flights(raw_data)
    return { best_flights: [] } unless raw_data && raw_data[0] && raw_data[0][2]
    
    # Parse the nested JSON string
    inner_data = JSON.parse(raw_data[0][2])
    
    # Flights can be at index 2, 3, 4, etc. - collect from all sections
    flights_arrays = []
    (2..10).each do |idx|
      section = inner_data[idx]
      if section.is_a?(Array) && section.length > 0
        # Check if this looks like a flights section
        if section[0].is_a?(Array) && section[0][0].is_a?(Array)
          flights_arrays << section
        end
      end
    end
    
    best_flights = []
    
    flights_arrays.each do |flights_array|
      flights_array.each do |flight_group|
      # Skip nil, false, or invalid entries
      next unless flight_group.is_a?(Array) && flight_group[0].is_a?(Array)
      
      flight_data = flight_group[0]
      flight_info = flight_data[0]
      
      next unless flight_info.is_a?(Array)
      
      # Extract basic flight info
      airline_code = flight_info[0]
      airline_names = flight_info[1] || []
      segments = flight_info[2] || []
      
      departure_airport = flight_info[3]
      departure_date = flight_info[4]
      departure_time = flight_info[5]
      arrival_airport = flight_info[6]
      arrival_date = flight_info[7]
      arrival_time = flight_info[8]
      duration_minutes = flight_info[9]
      stops_count = flight_info[10] || 0
      
      # Price info is at flight_info[22][7]
      price_data = flight_info[22]
      price_cents = price_data && price_data[7] ? price_data[7] : nil
      
      # Ensure segments is an array
      segments = flight_info[2].is_a?(Array) ? flight_info[2] : []
      
      # Build flight object
      flight = {
        departure_airport: {
          code: departure_airport,
          name: extract_airport_name(segments[0], departure_airport)
        },
        arrival_airport: {
          code: arrival_airport,
          name: extract_airport_name(segments[0], arrival_airport)
        },
        duration: duration_minutes,
        airplane: extract_airplane(segments[0]),
        airline: airline_names[0],
        airline_code: airline_code,
        extensions: extract_extensions(segments[0]),
        carbon_emissions: extract_carbon_emissions(segments[0]),
        price: price_cents ? (price_cents / 100.0).round(2) : nil,
        departure_time: format_datetime(departure_date, departure_time),
        arrival_time: format_datetime(arrival_date, arrival_time),
        stops: stops_count,
        segments: extract_segments(segments)
      }
      
        best_flights << flight
      end
    end
    
    { best_flights: best_flights }
  end
  
  def extract_airport_name(segment, airport_code)
    return airport_code unless segment
    # Airport name is at index 4 or 5 in segment
    segment[4] || segment[5] || airport_code
  end
  
  def extract_airplane(segment)
    return nil unless segment
    # Airplane model is at index 17
    segment[17]
  end
  
  def extract_extensions(segment)
    return [] unless segment
    # Extensions like wifi, power, legroom are in array at index 11
    extensions_array = segment[11] || []
    extensions = []
    
    extensions << "In-seat power & USB outlets" if extensions_array[1]
    extensions << "Wi-Fi" if extensions_array[10]
    
    # Legroom info at index 13
    if segment[13]
      extensions << "Average legroom (#{segment[13]})"
    end
    
    extensions
  end
  
  def extract_carbon_emissions(segment)
    return nil unless segment
    # Carbon emissions in grams at index 29
    emissions_grams = segment[29]
    return nil unless emissions_grams
    
    {
      this_flight: emissions_grams,
      typical_for_this_route: emissions_grams,
      difference_percent: 0
    }
  end
  
  def format_datetime(date_array, time_array)
    return nil unless date_array && date_array.is_a?(Array) && date_array.length >= 3
    
    year, month, day = date_array
    return nil unless year && month && day
    
    # time_array can be either an array [hour, minute] or a single integer (hour)
    if time_array.is_a?(Array)
      hour = time_array[0] || 0
      minute = time_array[1] || 0
    elsif time_array.is_a?(Integer)
      hour = time_array
      minute = 0
    else
      hour = 0
      minute = 0
    end
    
    sprintf("%04d-%02d-%02dT%02d:%02d:00-03:00", year, month, day, hour, minute)
  end
  
  def extract_segments(segments_array)
    segments_array.map do |segment|
      next nil unless segment
      
      {
        departure_airport: segment[3],
        arrival_airport: segment[6],
        departure_time: format_datetime(segment[19], segment[8]),
        arrival_time: format_datetime(segment[20], segment[10]),
        duration: segment[11],
        airline: segment[22] ? segment[22][3] : nil,
        flight_number: segment[22] ? "#{segment[22][0]}#{segment[22][1]}" : nil,
        airplane: segment[16]
      }
    end.compact
  end
end