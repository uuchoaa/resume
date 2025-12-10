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
    "f.sid=-4382590000827567880&bl=boq_travel-frontend-flights-ui_20251209.02_p0&hl=pt-BR&soc-app=162&soc-platform=1&soc-device=1&_reqid=46619&rt=c"
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
    request['X-Goog-BatchExecute-Bgr'] = '[";OCa4Jn7QAAZyDDXqUgxfKJeaEkPb4oAmADQBEArZ1KowcJzKpuSIzMqKFlnhpXZmbGosDbNd4JvlfQ_LFszqZoKtoiOZzeItDIkrf1KEHwAAAC9PAAAAAnUBB2MAQ5L-rDbhhGFqe1VStghsnP1nYgl7oNEKiaeCgyo4kjYAXA7TP_Ffa4WVe8CN0fe7xD5JfbXXwi3KNFvQYq7Nkuc780yEAzurOYUYkAx1lJxuZXmnqhcsEGmDQ5vXltWMPEb1uJww_kGjsF4js6tFGq_jrD7WSw1Lx3grbMcEKCLYW3UNs45Q0VjhYnDUBJsNjWLIwpW-hLXNf_eJQ1vcSkywS-0yY7FvRJees6ClGk_LPl87DbBxjdfy-k_3fJjE_jjoSyu4cNMqtYbq36huIGCC6OnzIlkHqyEy8OvvPYzShzCxR2-0YKmnYNB_Docp2S_eUIO5VKiyifM2qFxv5UjJ08QKWzGhGV9kI3zVxofuloPjLsnrKSO2CSJcNa-DSkROiJEMiAK07nJPUKVXhnBZYnNWh5xCHGvY1ZHh6q1pPW0Pq6Hgy13OH5zDec0S8afZhziVZpd9hOJmRLZPJ3HKFiwIK90hePDkOm-qOtbQ_2Ck_P8s9URzJTaQr-wDSXduHdL-628MopFdUyWL3duqPlIUnHk0N2-xImScrzlroCoYv40eQnwn3_BFzyN2kwLkO218QJNkO4Jk0AxYYFCargtvIc7gjqeufIvjEfSleKtcFOGbl3uDKF9E5KtuhXkkt1LSlTHDDS_LQjyGqwyso5uATCjvIMmD6tCbvyOqTRoWAsOtbl41VTRZQwwhoAMVpLL-cNoq-3gnyTK2mWoWPvhnlBgA0yaLzGguSl1YR5DADn1bHLIfPhA3o0BAtJbt0-nB2Ijc_G7ibw2UGiOEjYb74tFqU-T4Sea26n8NHAjmylDDVoFnpe2WZfyRcJpr-8J2Atu3yomD8B1fBTOud1IVVU0ebK5fzZ1Xg7zhlbAhMUaAUH5YOaTgosDmfQtQ81ejmkJGCAAMtWFnVCeyrq1Dgvcn36M3S8J9r8_WWxns3FHwcbAgR2hHcp1ApLtXMI7VylQ1DmrMHvDCXT-Ihs0mP_oJQHal7ySo7xC1SBqX1MFu5SouZUhVKsnu0yhVykdF7DGGmXlgjSIRcRe8wYMB4gOxnLSiv8c5eknuqcy2RPeMW3MdFyIxE5yOtXnPKApRpjmrHRPXOzNR4gKCRtDo6idg4FNeuHz_M1U516iOib_YVLBlpbYAGy-Ua-R3Wkh4fMsCPqJZQzYPaNVXo6qh5YXRhpigmamNGoFC4Q",null,null,151,38,null,null,0,"5"]'

    # Build the payload
    request.body = build_payload(origin, destination, departure_date, return_date)

    request
  end

  # Location type constants for Google Flights API
  AIRPORT_TYPE = 0  # Specific airport (e.g., CGH, GRU)
  CITY_TYPE = 4     # City/metro area (e.g., /m/022pfm for São Paulo)

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
            [[[origin_code(origin), AIRPORT_TYPE]]],
            [[[destination_code(destination), AIRPORT_TYPE]]],
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
            [[[destination_code(destination), AIRPORT_TYPE]]],
            [[[origin_code(origin), AIRPORT_TYPE]]],
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
    # Return the airport code as-is
    # Google Flights accepts IATA airport codes directly
    # Use AIRPORT_TYPE (0) to search for specific airport
    origin.upcase
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
      
      # Skip invalid entries (alliance codes, incomplete data, etc.)
      # Valid flights must have departure/arrival airports, duration, and price
      next unless departure_airport && arrival_airport && duration_minutes && price_cents
      
      # Extract flight number from first segment
      flight_number = extract_flight_number(segments[0])
      
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
        flight_number: flight_number,
        extensions: extract_extensions(segments[0]),
        emissions: extract_carbon_emissions(segments[0]),
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
  
  def extract_flight_number(segment)
    return nil unless segment && segment[22]
    # Flight number is composed of airline code and flight number at indices 0 and 1
    "#{segment[22][0]}#{segment[22][1]}"
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