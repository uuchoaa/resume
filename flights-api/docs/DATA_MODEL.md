# Google Flights API - Data Model & Parsing Guide

This document details the reverse-engineered data structures used by Google Flights' internal API.

## Table of Contents

- [Request Structure](#request-structure)
- [Response Structure](#response-structure)
- [Flight Data Model](#flight-data-model)
- [Location Types](#location-types)
- [Common Gotchas](#common-gotchas)

## Request Structure

### Endpoint

```
POST https://www.google.com/_/FlightsFrontendUi/data/travel.frontend.flights.FlightsFrontendService/GetShoppingResults
```

### Required Headers

The API requires specific anti-bot headers that expire periodically:

```ruby
# Standard headers
'Accept': '*/*'
'Accept-Encoding': 'gzip, deflate, br, zstd'
'Accept-Language': 'pt-BR,pt;q=0.9'
'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
'Origin': 'https://www.google.com'
'Referer': 'https://www.google.com/travel/flights'
'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'

# Critical anti-bot headers (expire frequently)
'X-Browser-Validation': 'AUXUCdutEJ+6gl6bYtz7E2kgIT4='
'X-Goog-Ext-259736195-Jspb': '["pt-BR","BR","BRL",1,null,[180],null,null,7,[]]'
'X-Goog-BatchExecute-Bgr': '[";OCa4Jn7QAAZyDDXqUgxf...]'  # Very long token
'X-Same-Domain': '1'
```

### Query Parameters

```
f.sid=-4382590000827567880
bl=boq_travel-frontend-flights-ui_20251209.02_p0  # Changes daily
hl=pt-BR
soc-app=162
soc-platform=1
soc-device=1
_reqid=46619
rt=c
```

### Request Payload

The payload is form-encoded with a single parameter `f.req` containing a JSON array:

```json
[
  null,
  "[nested_json_string]"
]
```

The inner JSON string structure:

```json
[
  [],
  [
    null,
    null,
    1,
    null,
    [],
    1,
    [1, 0, 0, 0],
    null,
    null,
    null,
    null,
    null,
    null,
    [
      // Outbound leg
      [
        [[["CGH", 0]]],     // Origin: airport code + type
        [[["JPA", 0]]],     // Destination: airport code + type
        null,
        0,
        null,
        null,
        "2026-02-06",       // Departure date
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        3
      ],
      // Return leg
      [
        [[["JPA", 0]]],     // Origin (return)
        [[["CGH", 0]]],     // Destination (return)
        null,
        0,
        null,
        null,
        "2026-02-27",       // Return date
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        3
      ]
    ],
    null,
    null,
    null,
    1
  ],
  0,
  0,
  0,
  1
]
```

## Location Types

Google Flights uses numeric types to distinguish between airports and cities:

```ruby
AIRPORT_TYPE = 0  # Specific airport (e.g., CGH, GRU, JFK)
CITY_TYPE = 4     # City/metro area (e.g., /m/022pfm for São Paulo)
```

### Examples

**Specific Airport:**
```json
[[["CGH", 0]]]  // Congonhas Airport only
```

**City (any airport):**
```json
[[["/m/022pfm", 4]]]  // Any São Paulo airport (CGH, GRU, VCP)
```

### Airport vs City Codes

- **Airport codes**: Standard IATA 3-letter codes (CGH, GRU, JFK, LAX)
- **City codes**: Wikidata/Freebase identifiers starting with `/m/`

Common São Paulo airports:
- `CGH` - Congonhas (domestic)
- `GRU` - Guarulhos (international)
- `VCP` - Viracopos (Campinas)

## Response Structure

### Response Format

The response body starts with a security prefix that must be stripped:

```
)]}'

```

After the prefix, the response contains multiple newline-separated JSON objects:

```
123
[json_object_1]
456
[json_object_2]
```

### Finding Flight Data

1. Parse all JSON objects from the response
2. Select the largest object (contains flight data)
3. Extract `raw_data[0][2]` which contains a JSON string
4. Parse this nested JSON string to get `inner_data`
5. Flight sections are typically at indices 2, 3, 4, etc.

### Flight Section Structure

Each section contains an array of flight groups. Each flight group structure:

```ruby
[
  [
    [
      flight_info_array  # Main flight data at index [0][0]
    ],
    # Additional metadata...
  ],
  nil,
  false,
  false,
  [...]
]
```

## Flight Data Model

### Flight Info Array Structure

The `flight_info` array contains flight details at specific indices:

| Index | Field | Type | Description |
|-------|-------|------|-------------|
| 0 | `airline_code` | String | Airline code (e.g., "LA", "G3") |
| 1 | `airline_names` | Array | Full airline names (e.g., ["LATAM"]) |
| 2 | `segments` | Array | Flight segment details |
| 3 | `departure_airport` | String | Departure airport IATA code |
| 4 | `departure_date` | Array | [year, month, day] |
| 5 | `departure_time` | Array | [hour, minute] |
| 6 | `arrival_airport` | String | Arrival airport IATA code |
| 7 | `arrival_date` | Array | [year, month, day] |
| 8 | `arrival_time` | Array | [hour, minute] |
| 9 | `duration_minutes` | Integer | Total flight duration in minutes |
| 10 | `stops_count` | Integer | Number of stops (0 = direct) |
| 22 | `price_data` | Array | Price information |

### Price Data (Index 22)

```ruby
price_data = flight_info[22]
price_cents = price_data[7]  # Price in cents
price_brl = (price_cents / 100.0).round(2)
```

### Segment Structure

Each segment (in `flight_info[2]`) contains:

| Index | Field | Type | Description |
|-------|-------|------|-------------|
| 3 | `departure_airport` | String | Segment departure airport |
| 6 | `arrival_airport` | String | Segment arrival airport |
| 8 | `departure_time` | Array | [hour, minute] |
| 10 | `arrival_time` | Array | [hour, minute] |
| 11 | `duration` | Integer | Segment duration in minutes |
| 16 | `airplane` | Mixed | Aircraft type code |
| 17 | `airplane_model` | String | Aircraft model name |
| 19 | `departure_date` | Array | [year, month, day] |
| 20 | `arrival_date` | Array | [year, month, day] |
| 22 | `airline_info` | Array | Detailed airline info |

### Airline Info in Segment (Index 22)

```ruby
airline_info = segment[22]
airline_code = airline_info[0]      # e.g., "LA"
flight_number = airline_info[1]     # e.g., "3824"
full_flight_number = "#{airline_code}#{flight_number}"  # "LA3824"
airline_name = airline_info[3]      # e.g., "LATAM"
```

### Amenities/Extensions (Index 11)

```ruby
extensions_array = segment[11] || []

amenities = []
amenities << "In-seat power & USB outlets" if extensions_array[1]
amenities << "Wi-Fi" if extensions_array[10]
amenities << "Average legroom (#{segment[13]})" if segment[13]
```

### Date/Time Formatting

Convert array format to ISO 8601:

```ruby
def format_datetime(date_array, time_array)
  # date_array = [2026, 2, 6]
  # time_array = [19, 40]
  
  year, month, day = date_array
  hour = time_array[0] || 0
  minute = time_array[1] || 0
  
  sprintf("%04d-%02d-%02dT%02d:%02d:00-03:00", 
          year, month, day, hour, minute)
  # => "2026-02-06T19:40:00-03:00"
end
```

## Output Flight Object

The final structured flight object:

```ruby
{
  departure_airport: {
    code: "CGH",
    name: "Aeroporto de São Paulo/Congonhas–Deputado Freitas Nobre"
  },
  arrival_airport: {
    code: "JPA",
    name: "Aeroporto Internacional Presidente Castro Pinto"
  },
  duration: 190,                              # minutes
  airplane: "Airbus A320",
  airline: "LATAM",
  airline_code: "LA",
  flight_number: "LA3824",
  extensions: [
    "In-seat power & USB outlets",
    "Wi-Fi",
    "Average legroom (2)"
  ],
  emissions: nil,                             # Carbon emissions (if available)
  price: 1850.0,                              # BRL
  departure_time: "2026-02-06T19:40:00-03:00",
  arrival_time: "2026-02-06T22:50:00-03:00",
  stops: 0,
  segments: [
    {
      departure_airport: "CGH",
      arrival_airport: "JPA",
      departure_time: nil,
      arrival_time: "2026-02-06T22:50:00-03:00",
      duration: 190,
      airline: "LATAM",
      flight_number: "LA3824",
      airplane: 1
    }
  ]
}
```

## Common Gotchas

### 1. Token Expiration

The anti-bot tokens (`X-Goog-BatchExecute-Bgr`, etc.) expire frequently. Symptoms:
- Empty responses
- HTTP 400 errors
- Different results than web interface

**Solution:** Capture a new HAR file and update tokens.

### 2. Location Type Confusion

Using `CITY_TYPE` (4) instead of `AIRPORT_TYPE` (0) will return flights from all airports in a metropolitan area.

```ruby
# ❌ Wrong - returns flights from CGH, GRU, VCP
[[["CGH", 4]]]

# ✅ Correct - returns only CGH flights
[[["CGH", 0]]]
```

### 3. Dynamic Pricing

Flight prices change constantly. The same search moments apart may return different prices. This is normal behavior.

### 4. Invalid Flight Entries

The response may contain invalid entries (e.g., alliance codes). Always validate:

```ruby
# Skip entries without required fields
next unless departure_airport && arrival_airport && duration && price_cents
```

### 5. Multiple Flight Sections

Google returns flights in multiple sections (indices 2, 3, 4, etc.). You may need to parse multiple sections to get all flights:

```ruby
(2..10).each do |idx|
  section = inner_data[idx]
  next unless section.is_a?(Array) && section.length > 0
  # Parse flights from this section...
end
```

### 6. Nested JSON Strings

The response contains JSON within JSON within JSON. Pay attention to when you need to parse strings vs access objects directly:

```ruby
raw_data = largest_json_object
inner_data = JSON.parse(raw_data[0][2])  # Parse nested JSON string
```

### 7. Array Index Fragility

The array indices are undocumented and may change if Google updates their API. Monitor for:
- Unexpected nil values
- Type mismatches
- Missing fields

## Testing

Always validate parsing changes against test data:

```bash
# Run parser tests (fast)
ruby test/parser_test.rb

# Run integration tests (makes real API call)
rake test_integration
```

## Debugging Tips

### Capture New HAR File

1. Open Chrome DevTools (Network tab)
2. Visit Google Flights: https://www.google.com/travel/flights
3. Perform a search
4. Find the `GetShoppingResults` request
5. Right-click → "Save all as HAR"

### Inspect Response Structure

```ruby
# Save raw response
File.write('response.json', response_body)

# Parse and explore sections
inner_data = JSON.parse(raw_data[0][2])
inner_data.each_with_index do |section, i|
  puts "Section #{i}: #{section.class} - Length: #{section.length}"
end
```

### Compare Request Payloads

```ruby
# Extract payload from HAR
har = JSON.parse(File.read('capture.har'))
entry = har['log']['entries'].find { |e| e['request']['url'].include?('GetShoppingResults') }
params = URI.decode_www_form(entry['request']['postData']['text'])
freq = params.find { |k, v| k == 'f.req' }[1]
File.write('payload.json', JSON.pretty_generate(JSON.parse(freq)))
```

## Further Reading

- [Google Flights Search URL Format](https://www.google.com/travel/flights)
- [IATA Airport Codes](https://www.iata.org/en/publications/directories/code-search/)
- [Wikidata](https://www.wikidata.org/) - Source of city codes
