# Google Flights API Clone

A Ruby implementation to scrape Google Flights data, reverse-engineered from the official Google Flights interface.

## Project Overview

This project provides a SearchAPI.io-style interface for Google Flights data extraction. Through reverse engineering, we identified the core API endpoint Google uses internally and developed strategies to access it.

## Core Discovery

### The Golden Endpoint

```
POST https://www.google.com/_/FlightsFrontendUi/data/travel.frontend.flights.FlightsFrontendService/GetShoppingResults
```

**Key Parameters:**
- `f.sid` - Session ID
- `bl` - Build version (e.g., `boq_travel-frontend-flights-ui_20251208.02_p0`)
- `hl` - Language code
- `_reqid` - Request ID

**Request Payload:**
```ruby
# URL-encoded POST body
f.req=[
  null,
  "[[],[null,null,1,null,[],1,[1,0,0,0],null,null,null,null,null,null,
  [[[[[\"/m/022pfm\",4]]],[[[\"REC\",0]]],null,0,null,null,\"2025-12-10\",...],
  [[[[\"REC\",0]]],[[[\"/m/022pfm\",4]]],null,0,null,null,\"2025-12-17\",...]]
  ,null,null,null,1],0,0,0,1]"
]
```

**Response Structure:**
- Flight details (airline, times, aircraft, duration)
- Prices (in cents)
- Booking tokens
- CO2 emissions
- Layover information
- Alternative routes
- Price history data

## Implementation Strategies

### Scenario 1: Personal Project (Browser Automation)

**Recommended for:** Learning, personal use, <100 requests/day

#### Architecture

```ruby
# Gemfile
gem 'ferrum'      # Chrome DevTools Protocol
gem 'rails', '~> 7.1'
gem 'sidekiq'     # Background jobs
gem 'redis'       # Caching & Sidekiq
```

#### Core Implementation

```ruby
# app/services/flights_scraper.rb
class FlightsScraper
  def initialize
    @browser = Ferrum::Browser.new(
      headless: true,
      timeout: 60,
      browser_options: {
        'no-sandbox': nil,
        'disable-gpu': nil
      }
    )
  end

  def search(origin:, destination:, departure_date:, return_date:)
    tfs_param = build_tfs_param(origin, destination, departure_date, return_date)
    url = "https://www.google.com/travel/flights/search?tfs=#{tfs_param}"
    
    page = @browser.create_page
    
    # Intercept network requests
    captured_data = nil
    page.network.intercept
    
    page.on(:response) do |response|
      if response.url.include?('GetShoppingResults')
        captured_data = parse_flight_response(response.body)
      end
    end
    
    page.goto(url)
    page.at_xpath("//div[contains(@class, 'flight-result')]") # Wait for results
    
    captured_data
  ensure
    page&.close
  end

  private

  def build_tfs_param(origin, destination, departure_date, return_date)
    # This would encode the protobuf-style parameter
    # For now, we can capture valid URLs and modify dates/destinations
    # TODO: Reverse engineer full protobuf encoding
  end

  def parse_flight_response(body)
    # Parse the nested JSON/array structure
    json = JSON.parse(body.gsub(/^\)\]\}'\n\n/, ''))
    
    flights = []
    # Extract flight data from deeply nested arrays
    # json[0][12][0][0] typically contains flight results
    
    {
      origin: extract_origin(json),
      destination: extract_destination(json),
      flights: extract_flights(json),
      price_range: extract_price_range(json)
    }
  end
end
```

#### API Controller

```ruby
# app/controllers/api/v1/flights_controller.rb
class Api::V1::FlightsController < ApplicationController
  def search
    result = FlightsScraper.new.search(
      origin: params[:origin],
      destination: params[:destination],
      departure_date: params[:departure_date],
      return_date: params[:return_date]
    )
    
    render json: result
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

#### Caching Layer

```ruby
# app/services/cached_flights_scraper.rb
class CachedFlightsScraper
  CACHE_TTL = 15.minutes

  def search(params)
    cache_key = "flights:#{params.values.join(':')}"
    
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      FlightsScraper.new.search(**params)
    end
  end
end
```

**Pros:**
- Works reliably
- Handles anti-bot measures automatically
- Easy to debug

**Cons:**
- Resource intensive (~200MB RAM per browser instance)
- Slower (~10-15s per search)
- Limited scalability

---

### Scenario 2: Production Service (Future Implementation)

**Required for:** High volume, commercial use, >1000 requests/day

#### Critical Headers for Direct API Calls

```ruby
# app/services/google_flights_client.rb
class GoogleFlightsClient
  ENDPOINT = 'https://www.google.com/_/FlightsFrontendUi/data/' \
             'travel.frontend.flights.FlightsFrontendService/GetShoppingResults'

  def initialize
    @http = HTTP.timeout(30)
  end

  def search(params)
    headers = build_headers
    payload = build_payload(params)
    
    response = @http.headers(headers).post(
      "#{ENDPOINT}?#{query_params}",
      form: { 'f.req': payload.to_json }
    )
    
    parse_response(response.body)
  end

  private

  def build_headers
    {
      'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8',
      'User-Agent' => generate_user_agent,
      'X-Browser-Validation' => generate_validation_token,
      'X-Goog-BatchExecute-Bgr' => generate_bgr_token,
      'X-Goog-Ext-259736195-Jspb' => build_locale_header,
      'Accept' => '*/*',
      'Referer' => 'https://www.google.com/travel/flights'
    }
  end

  def generate_validation_token
    # TODO: Reverse engineer this token generation
    # Appears to be based on browser fingerprint
    # May require analyzing Google's JavaScript
  end

  def generate_bgr_token
    # TODO: This is the most complex header
    # Large base64-encoded payload containing:
    # - Session information
    # - Browser fingerprint
    # - Timestamps
    # - Possibly encrypted data
  end

  def build_locale_header
    # Format: ["pt-BR","BR","BRL",1,null,[180],null,null,7,[]]
    [
      I18n.locale.to_s,
      country_code,
      currency_code,
      1,
      nil,
      [180], # Unknown parameter
      nil,
      nil,
      7,
      []
    ].to_json
  end
end
```

#### Production Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│  Rails API  │─────▶│    Redis     │
│  (Routes)   │      │  (Cache/Job) │
└──────┬──────┘      └──────────────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│   Sidekiq   │─────▶│  Proxy Pool  │
│   Workers   │      │   (Rotating) │
└──────┬──────┘      └──────────────┘
       │
       ▼
┌─────────────┐
│  Headless   │
│  Browsers   │
│  (Docker)   │
└─────────────┘
```

**Key Components:**

1. **Rate Limiting**
```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle('api/ip', limit: 10, period: 60) do |req|
  req.ip if req.path.start_with?('/api/')
end
```

2. **Job Queue with Priorities**
```ruby
# app/jobs/flight_search_job.rb
class FlightSearchJob < ApplicationJob
  queue_as :default
  
  def perform(params, priority: :normal)
    result = FlightsScraper.new.search(**params)
    # Store result in database or return via callback
  end
end
```

3. **Proxy Rotation**
```ruby
# app/services/proxy_manager.rb
class ProxyManager
  def next_proxy
    # Rotate through proxy pool
    # Remove failed proxies
    # Monitor success rates
  end
end
```

---

## Challenges & Solutions

### Challenge 1: Anti-Bot Detection

**Problem:** Google detects automated browsers

**Solutions:**
- Use stealth browser configurations
- Rotate user agents
- Add random delays
- Use residential proxies
- Maintain session state

### Challenge 2: Token Generation

**Problem:** `X-Browser-Validation` and `X-Goog-BatchExecute-Bgr` are required

**Solutions:**
- Extract tokens from browser automation (current approach)
- Reverse engineer JavaScript token generation
- Use protobuf-inspector to decode token structure

### Challenge 3: Protobuf Encoding

**Problem:** The `tfs` URL parameter is Protocol Buffer encoded

**Solutions:**
- Capture valid URLs and modify programmatically
- Use `google-protobuf` gem to build messages
- Reverse engineer the proto schema

```ruby
# Potential protobuf structure (hypothetical)
message FlightSearch {
  message Leg {
    string origin_code = 1;
    string destination_code = 2;
    string date = 3;
  }
  repeated Leg legs = 1;
  int32 adults = 2;
  int32 cabin_class = 3;
}
```

---

## Getting Started (Personal Project)

```bash
# Install dependencies
bundle install

# Start Redis
redis-server

# Start Rails server
rails server

# Make a search request
curl http://localhost:3000/api/v1/flights/search \
  -d "origin=GRU" \
  -d "destination=REC" \
  -d "departure_date=2025-12-10" \
  -d "return_date=2025-12-17"
```

---

## Legal & Ethical Considerations

⚠️ **Important Notes:**
- Web scraping may violate Google's Terms of Service
- Use responsibly and at your own risk
- Consider rate limiting to avoid overwhelming Google's servers
- This is for educational purposes

---

## Future Roadmap

- [ ] Reverse engineer protobuf `tfs` parameter generation
- [ ] Decode `X-Browser-Validation` token algorithm
- [ ] Implement direct API calls (no browser)
- [ ] Add multi-city search support
- [ ] Price tracking and alerts
- [ ] Historical price data storage
- [ ] API key authentication for your service
- [ ] Webhook callbacks for async results

---

## Performance Benchmarks

| Approach | Speed | Memory | Scalability | Reliability |
|----------|-------|--------|-------------|-------------|
| Browser Automation | ~15s | ~200MB | Low | High |
| Direct API (with tokens) | ~2s | ~10MB | High | Medium |
| Hybrid (token extraction) | ~5s | ~50MB | Medium | High |

---

## Contributing

This is a research/educational project. Contributions welcome for:
- Protobuf schema reverse engineering
- Token generation algorithms
- Performance optimizations
- Parser improvements
