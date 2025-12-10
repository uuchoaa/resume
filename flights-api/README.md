# Google Flights API Client

A Ruby client for searching flights on Google Flights with CLI support.

## Features

- Search for round-trip flights
- Multiple output formats (table, compact, JSON)
- Real API integration with Google Flights
- Comprehensive test suite

## Documentation

- **[Data Model & Parsing Guide](docs/DATA_MODEL.md)** - Detailed documentation of request/response structures, data parsing, and reverse-engineered API details
- **[Refactoring & Design Patterns](docs/REFACTORING.md)** - Design patterns and strategies for improving the parser implementation
- **[Token Management & Browser Automation](docs/TOKEN_MANAGEMENT.md)** - Lazy-loading token system with browser automation using Ferrum
- **[Rails API Integration](docs/RAILS_API.md)** - Production-ready Rails API with Swagger, authentication, rate limiting, caching, and best practices

## Installation

```bash
bundle install
```

## Usage

### Command Line Interface

Search for flights using the CLI:

```bash
# Basic search
ruby flights_cli.rb -o CGH -d JPA --departure 2026-02-06 --return 2026-02-27

# Compact format
ruby flights_cli.rb -o CGH -d JPA --departure 2026-02-06 --return 2026-02-27 --format compact

# JSON output
ruby flights_cli.rb -o CGH -d JPA --departure 2026-02-06 --return 2026-02-27 --format json

# Limit results
ruby flights_cli.rb -o CGH -d JPA --departure 2026-02-06 --return 2026-02-27 --max 5
```

#### CLI Options

Required:
- `-o, --origin AIRPORT` - Origin airport code (e.g., CGH, GRU)
- `-d, --destination AIRPORT` - Destination airport code (e.g., JPA)
- `--departure DATE` - Departure date (YYYY-MM-DD)
- `--return DATE` - Return date (YYYY-MM-DD)

Optional:
- `--format FORMAT` - Output format: table, json, compact (default: table)
- `--max LIMIT` - Maximum number of flights to show
- `-h, --help` - Show help message

### Ruby API

```ruby
require_relative 'google_flights_client'

client = GoogleFlightsClient.new

result = client.search(
  origin: 'CGH',
  destination: 'JPA',
  departure_date: '2026-02-06',
  return_date: '2026-02-27'
)

result[:best_flights].each do |flight|
  puts "#{flight[:airline]} #{flight[:flight_number]} - R$ #{flight[:price]}"
end
```

## Testing

### Run all tests
```bash
rake test
```

### Run specific test suites
```bash
# Parser tests (fast, uses cached data)
ruby test/parser_test.rb

# Client tests
ruby test/client_test.rb

# Integration tests (makes real API calls)
rake test_integration
```

## Architecture

- `google_flights_client.rb` - Main client class for Google Flights API
- `flights_cli.rb` - Command-line interface
- `test/` - Test suite
  - `parser_test.rb` - Tests for response parsing
  - `client_test.rb` - Tests for client functionality
  - `integration_test.rb` - Integration tests with real API calls
  - `assets/` - Sample response data for testing
  - `snapshots/` - Cached API responses for integration tests

## How It Works

The client sends POST requests to Google Flights' internal API endpoint, mimicking browser behavior. It:

1. Builds a properly formatted request with all necessary headers and tokens
2. Sends the request to Google's FlightsFrontendService
3. Parses the complex nested JSON response
4. Extracts flight information (prices, times, airlines, etc.)
5. Returns structured data

### Location Types

The API uses location type constants:
- `AIRPORT_TYPE = 0` - Specific airport (e.g., CGH, GRU)
- `CITY_TYPE = 4` - City/metro area (e.g., all São Paulo airports)

## Limitations

- Requires valid API tokens that may expire periodically
- Response format may change as Google updates their API
- Rate limiting may apply

## License

MIT
