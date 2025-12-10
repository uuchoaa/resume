# Test Suite Documentation

## Overview

The Google Flights Parser includes a comprehensive test suite with **64 automated tests** covering all aspects of the flight data extraction and parsing system.

## Test Results

```
✅ 64 tests
✅ 146 assertions
✅ 0 failures
✅ 0 errors
⏭️  4 intentional skips
```

## Test Organization

### Directory Structure

```
flights-api/
├── test/
│   ├── parser_test.rb          # 21 tests - Flight extraction & validation
│   ├── helper_methods_test.rb  # 26 tests - Helper method unit tests
│   ├── client_test.rb          # 17 tests - HTTP client integration tests
│   ├── test_all.rb            # Test suite runner
│   └── archive/               # Old test files
├── test_client.rb             # Manual integration test
├── Rakefile                   # Test task definitions
└── GoogleFlightsClient.rb     # Main implementation
```

## Test Categories

### 1. Parser Tests (`parser_test.rb`) - 21 tests

Tests the core flight data extraction and parsing functionality.

**Covered Areas:**
- ✅ Client initialization
- ✅ Flight extraction from Google's response format
- ✅ Required field validation (departure_airport, arrival_airport, duration, etc.)
- ✅ Airport structure (code + name hash)
- ✅ Price extraction and validation
- ✅ Price conversion from cents to BRL
- ✅ Duration validation (positive integers)
- ✅ Airline code validation (2+ uppercase alphanumeric)
- ✅ Airport code validation (3-letter uppercase)
- ✅ Date/time format validation (ISO 8601)
- ✅ Segments array structure
- ✅ Extensions array structure
- ✅ Stops count validation
- ✅ Multiple flight extraction
- ✅ Price variation across flights
- ✅ Edge case handling (nil, empty inputs)

**Key Tests:**
```ruby
test_extract_flights_returns_hash
test_flight_has_required_fields
test_price_conversion_from_cents
test_datetime_format
test_multiple_flights_extracted
test_airport_codes_are_three_letters
```

### 2. Helper Methods Tests (`helper_methods_test.rb`) - 26 tests

Unit tests for all helper methods used in flight data extraction.

**Covered Methods:**

#### `format_datetime` (6 tests)
- ✅ Array time format `[hour, minute]`
- ✅ Integer time format (hour only)
- ✅ Nil date handling
- ✅ Incomplete date handling
- ✅ Nil time handling
- ✅ Single-digit value formatting

#### `extract_airplane` (4 tests)
- ✅ Basic extraction from segment[17]
- ✅ Nil segment handling
- ✅ Short segment handling
- ✅ Different aircraft models

#### `extract_airport_name` (4 tests)
- ✅ Extraction from segment[4]
- ✅ Extraction from segment[5]
- ✅ Fallback to airport code
- ✅ Empty segment handling

#### `extract_extensions` (6 tests)
- ✅ Power outlet detection
- ✅ WiFi detection
- ✅ Both power and WiFi
- ✅ Legroom information
- ✅ Nil segment handling
- ✅ No amenities handling

#### `extract_carbon_emissions` (3 tests)
- ✅ Basic emission data extraction
- ✅ Nil segment handling
- ✅ Missing data handling

#### `extract_segments` (3 tests)
- ✅ Basic segment structure
- ✅ Nil entry filtering
- ✅ Empty array handling

### 3. Client Integration Tests (`client_test.rb`) - 17 tests

Tests HTTP client functionality and integration points.

**Covered Areas:**

#### HTTP Request Building (5 tests)
- ✅ Returns proper Net::HTTP::Post object
- ✅ Sets all required headers
- ✅ Sets correct Content-Type
- ✅ Sets X-Same-Domain header
- ✅ Client reusability

#### Payload Building (4 tests)
- ✅ Contains origin airport
- ✅ Contains destination airport
- ✅ Contains departure/return dates
- ✅ Proper URL encoding structure
- ✅ Special character escaping

#### Response Handling (3 tests)
- ✅ Plain text body decoding
- ✅ Security prefix removal
- ✅ Empty body handling

#### Skipped Tests (4 intentional)
- ⏭️ Brotli decompression (requires compressed data)
- ⏭️ Actual search method (requires valid tokens)
- ⏭️ Connection error handling (requires network simulation)
- ⏭️ Timeout handling (requires timeout simulation)

## Running Tests

### Run All Tests
```bash
rake test
```

### Run Specific Test Suites
```bash
rake test_parser    # Parser tests only (21 tests)
rake test_helpers   # Helper method tests (26 tests)
rake test_client    # Client tests (17 tests)
```

### Alternative Runner
```bash
ruby test/test_all.rb
```

### Manual API Testing
```bash
./test_client.rb
# Warning: Requires valid API tokens
```

## Test Framework

**Technology Stack:**
- **Framework:** Minitest
- **Reporter:** minitest-reporters (SpecReporter)
- **Task Runner:** Rake

**Installation:**
```bash
gem install minitest-reporters
```

## Test Output

### Success Output
```
Started with run options --seed 12345

GoogleFlightsClientTest
  test_client_initialization                PASS (0.00s)
  test_extract_flights_returns_hash        PASS (0.00s)
  ...
  
HelperMethodsTest
  test_format_datetime_with_array_time     PASS (0.00s)
  ...

GoogleFlightsClientIntegrationTest
  test_build_request_returns_http_request  PASS (0.00s)
  ...

Finished in 0.01224s
64 tests, 146 assertions, 0 failures, 0 errors, 4 skips
```

## Test Data

### Sample Response
Tests use `last_response.json` containing real Google Flights API response data:
- 4+ flight options
- LATAM and Azul airlines
- GRU → REC route
- Multiple price points
- Various aircraft types

### Test Fixtures
- Static segments for helper method testing
- Mock response objects for client testing
- Edge case data (nil, empty arrays, malformed data)

## Coverage Areas

### ✅ Fully Covered
- Flight data extraction
- Helper method functionality
- HTTP request building
- Response parsing
- Error handling for edge cases
- Data validation and formatting

### ⚠️ Partial Coverage
- Network error handling (skipped - requires simulation)
- Brotli decompression (skipped - requires compressed data)
- Live API integration (manual test only)

### 🔄 Future Enhancements
- Add code coverage reporting (SimpleCov)
- Add performance benchmarks
- Add integration tests with mocked HTTP responses
- Add tests for token refresh mechanism

## Continuous Integration

The test suite is designed to run in CI/CD pipelines:

```yaml
# Example .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
      - run: gem install minitest-reporters
      - run: rake test
```

## Debugging Tests

### Run Single Test
```bash
ruby -I.:test test/parser_test.rb -n test_flight_has_required_fields
```

### Verbose Output
```bash
rake test TESTOPTS="-v"
```

### Show Backtraces
```bash
rake test --trace
```

## Test Maintenance

### Adding New Tests
1. Choose appropriate test file (parser/helper/client)
2. Follow naming convention: `test_description_of_what_is_tested`
3. Use descriptive assertion messages
4. Include both positive and negative test cases

### Updating Tests
When modifying `GoogleFlightsClient.rb`:
1. Run tests to identify failures
2. Update test expectations if behavior changed intentionally
3. Add new tests for new functionality
4. Ensure all tests pass before committing

## Summary

The test suite provides comprehensive coverage of the Google Flights Parser with:
- **64 automated tests** ensuring reliability
- **146 assertions** validating behavior
- **100% pass rate** on all executable tests
- **Organized structure** for easy maintenance
- **Multiple test categories** covering all components
- **Rake tasks** for convenient test execution

All core functionality is tested and validated, providing confidence in the parser's reliability and correctness.
