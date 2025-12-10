# Parser Refactoring & Design Patterns

This document outlines design patterns and refactoring strategies to improve the current parser implementation.

## Table of Contents

- [Current Problems](#current-problems)
- [Proposed Design Patterns](#proposed-design-patterns)
- [Implementation Examples](#implementation-examples)
- [Benefits](#benefits)
- [Migration Strategy](#migration-strategy)

## Current Problems

The current parser (`google_flights_client.rb`) has several code smells:

### 1. Magic Numbers Everywhere
```ruby
# What does this mean?
price_cents = flight_info[22][7]

# Or this?
airline_names = flight_info[1]
departure_airport = flight_info[3]
```

### 2. Deep Nesting
```ruby
flights_arrays.each do |flights_array|
  flights_array.each do |flight_group|
    next unless flight_group.is_a?(Array) && flight_group[0].is_a?(Array)
    flight_data = flight_group[0]
    flight_info = flight_data[0]
    # ... more nesting
  end
end
```

### 3. No Type Safety
- Arrays can contain anything
- No validation of data structure
- Silent failures when structure changes

### 4. Hard to Test
- Tightly coupled to response structure
- Difficult to mock dependencies
- Hard to test individual components

### 5. Fragile
- Any API change breaks multiple places
- No clear boundaries between concerns
- Difficult to maintain

## Proposed Design Patterns

### 1. Value Objects Pattern

**Purpose:** Encapsulate flight data in immutable, well-defined objects.

**Benefits:**
- Type safety
- Clear API
- Easy to test
- Self-documenting

**Implementation:**

```ruby
# lib/models/flight.rb
module GoogleFlights
  module Models
    class Flight
      attr_reader :departure_airport, :arrival_airport, :duration, :price,
                  :airline, :airline_code, :flight_number, :departure_time,
                  :arrival_time, :stops, :airplane, :extensions, :segments

      def initialize(**attrs)
        @departure_airport = attrs[:departure_airport]
        @arrival_airport = attrs[:arrival_airport]
        @duration = attrs[:duration]
        @price = attrs[:price]
        @airline = attrs[:airline]
        @airline_code = attrs[:airline_code]
        @flight_number = attrs[:flight_number]
        @departure_time = attrs[:departure_time]
        @arrival_time = attrs[:arrival_time]
        @stops = attrs[:stops]
        @airplane = attrs[:airplane]
        @extensions = attrs[:extensions] || []
        @segments = attrs[:segments] || []
      end

      def direct?
        stops == 0
      end

      def valid?
        !departure_airport.nil? && !arrival_airport.nil? && !price.nil?
      end

      def to_h
        {
          departure_airport: departure_airport.to_h,
          arrival_airport: arrival_airport.to_h,
          duration: duration,
          price: price,
          airline: airline,
          airline_code: airline_code,
          flight_number: flight_number,
          departure_time: departure_time,
          arrival_time: arrival_time,
          stops: stops,
          airplane: airplane,
          extensions: extensions,
          emissions: nil,
          segments: segments.map(&:to_h)
        }
      end
    end

    class Airport
      attr_reader :code, :name

      def initialize(code:, name:)
        @code = code
        @name = name
      end

      def to_h
        { code: code, name: name }
      end
    end

    class Segment
      attr_reader :departure_airport, :arrival_airport, :departure_time,
                  :arrival_time, :duration, :airline, :flight_number, :airplane

      def initialize(**attrs)
        @departure_airport = attrs[:departure_airport]
        @arrival_airport = attrs[:arrival_airport]
        @departure_time = attrs[:departure_time]
        @arrival_time = attrs[:arrival_time]
        @duration = attrs[:duration]
        @airline = attrs[:airline]
        @flight_number = attrs[:flight_number]
        @airplane = attrs[:airplane]
      end

      def to_h
        {
          departure_airport: departure_airport,
          arrival_airport: arrival_airport,
          departure_time: departure_time,
          arrival_time: arrival_time,
          duration: duration,
          airline: airline,
          flight_number: flight_number,
          airplane: airplane
        }
      end
    end
  end
end
```

**Usage:**
```ruby
flight = Models::Flight.new(
  departure_airport: Models::Airport.new(code: 'CGH', name: 'Congonhas'),
  arrival_airport: Models::Airport.new(code: 'JPA', name: 'João Pessoa'),
  price: 1850.0,
  duration: 190
)

flight.direct?  # => true
flight.valid?   # => true
flight.to_h     # => Hash representation
```

---

### 2. Data Mapper Pattern

**Purpose:** Separate mapping logic from parsing logic. Document all array indices in one place.

**Benefits:**
- Single source of truth for indices
- Easy to update when API changes
- Self-documenting code
- Testable in isolation

**Implementation:**

```ruby
# lib/parsers/flight_info_mapper.rb
module GoogleFlights
  module Parsers
    class FlightInfoMapper
      # Document all magic array indices
      AIRLINE_CODE = 0
      AIRLINE_NAMES = 1
      SEGMENTS = 2
      DEPARTURE_AIRPORT = 3
      DEPARTURE_DATE = 4
      DEPARTURE_TIME = 5
      ARRIVAL_AIRPORT = 6
      ARRIVAL_DATE = 7
      ARRIVAL_TIME = 8
      DURATION = 9
      STOPS = 10
      PRICE_DATA = 22

      # Nested indices
      module PriceData
        CENTS = 7
      end

      class << self
        def map(flight_info, segments_data = nil)
          return nil unless valid?(flight_info)

          segments_data ||= flight_info[SEGMENTS]

          {
            airline_code: extract_airline_code(flight_info),
            airline: extract_airline_name(flight_info),
            departure_airport: extract_departure_airport(flight_info, segments_data),
            arrival_airport: extract_arrival_airport(flight_info, segments_data),
            departure_time: extract_departure_time(flight_info),
            arrival_time: extract_arrival_time(flight_info),
            duration: extract_duration(flight_info),
            stops: extract_stops(flight_info),
            price: extract_price(flight_info),
            airplane: extract_airplane(segments_data),
            flight_number: extract_flight_number(segments_data),
            extensions: extract_extensions(segments_data),
            segments: extract_segments(segments_data)
          }
        end

        private

        def valid?(flight_info)
          return false unless flight_info.is_a?(Array)
          return false unless flight_info[DEPARTURE_AIRPORT]
          return false unless flight_info[ARRIVAL_AIRPORT]
          return false unless flight_info[DURATION]
          return false unless flight_info[PRICE_DATA]
          true
        end

        def extract_airline_code(flight_info)
          flight_info[AIRLINE_CODE]
        end

        def extract_airline_name(flight_info)
          names = flight_info[AIRLINE_NAMES]
          names.is_a?(Array) ? names.first : nil
        end

        def extract_departure_airport(flight_info, segments_data)
          code = flight_info[DEPARTURE_AIRPORT]
          name = extract_airport_name(segments_data&.first, code)
          Models::Airport.new(code: code, name: name)
        end

        def extract_arrival_airport(flight_info, segments_data)
          code = flight_info[ARRIVAL_AIRPORT]
          name = extract_airport_name(segments_data&.first, code)
          Models::Airport.new(code: code, name: name)
        end

        def extract_departure_time(flight_info)
          DateTimeFormatter.format(
            flight_info[DEPARTURE_DATE],
            flight_info[DEPARTURE_TIME]
          )
        end

        def extract_arrival_time(flight_info)
          DateTimeFormatter.format(
            flight_info[ARRIVAL_DATE],
            flight_info[ARRIVAL_TIME]
          )
        end

        def extract_duration(flight_info)
          flight_info[DURATION]
        end

        def extract_stops(flight_info)
          flight_info[STOPS] || 0
        end

        def extract_price(flight_info)
          price_data = flight_info[PRICE_DATA]
          return nil unless price_data

          price_cents = price_data[PriceData::CENTS]
          return nil unless price_cents

          (price_cents / 100.0).round(2)
        end

        def extract_airplane(segments_data)
          return nil unless segments_data&.first
          SegmentMapper::AIRPLANE_EXTRACTOR.call(segments_data.first)
        end

        def extract_flight_number(segments_data)
          return nil unless segments_data&.first
          SegmentMapper::FLIGHT_NUMBER_EXTRACTOR.call(segments_data.first)
        end

        def extract_extensions(segments_data)
          return [] unless segments_data&.first
          ExtensionsExtractor.extract(segments_data.first)
        end

        def extract_segments(segments_data)
          return [] unless segments_data.is_a?(Array)
          segments_data.map { |seg| SegmentMapper.map(seg) }.compact
        end

        def extract_airport_name(segment, airport_code)
          return airport_code unless segment
          segment[4] || segment[5] || airport_code
        end
      end
    end

    class SegmentMapper
      # Segment array indices
      DEPARTURE_AIRPORT = 3
      ARRIVAL_AIRPORT = 6
      DEPARTURE_TIME_IDX = 8
      ARRIVAL_TIME_IDX = 10
      DURATION = 11
      AIRPLANE = 16
      AIRPLANE_MODEL = 17
      DEPARTURE_DATE = 19
      ARRIVAL_DATE = 20
      AIRLINE_INFO = 22

      AIRPLANE_EXTRACTOR = ->(seg) { seg[AIRPLANE_MODEL] }
      FLIGHT_NUMBER_EXTRACTOR = ->(seg) do
        return nil unless seg[AIRLINE_INFO]
        "#{seg[AIRLINE_INFO][0]}#{seg[AIRLINE_INFO][1]}"
      end

      class << self
        def map(segment)
          return nil unless segment

          Models::Segment.new(
            departure_airport: segment[DEPARTURE_AIRPORT],
            arrival_airport: segment[ARRIVAL_AIRPORT],
            departure_time: DateTimeFormatter.format(segment[DEPARTURE_DATE], segment[DEPARTURE_TIME_IDX]),
            arrival_time: DateTimeFormatter.format(segment[ARRIVAL_DATE], segment[ARRIVAL_TIME_IDX]),
            duration: segment[DURATION],
            airline: segment[AIRLINE_INFO] ? segment[AIRLINE_INFO][3] : nil,
            flight_number: FLIGHT_NUMBER_EXTRACTOR.call(segment),
            airplane: segment[AIRPLANE]
          )
        end
      end
    end

    class DateTimeFormatter
      class << self
        def format(date_array, time_array)
          return nil unless date_array && date_array.is_a?(Array) && date_array.length >= 3

          year, month, day = date_array
          return nil unless year && month && day

          hour, minute = extract_time(time_array)

          sprintf("%04d-%02d-%02dT%02d:%02d:00-03:00", year, month, day, hour, minute)
        end

        private

        def extract_time(time_array)
          if time_array.is_a?(Array)
            [time_array[0] || 0, time_array[1] || 0]
          elsif time_array.is_a?(Integer)
            [time_array, 0]
          else
            [0, 0]
          end
        end
      end
    end

    class ExtensionsExtractor
      EXTENSIONS_IDX = 11
      POWER_USB = 1
      WIFI = 10
      LEGROOM = 13

      class << self
        def extract(segment)
          return [] unless segment

          extensions_array = segment[EXTENSIONS_IDX] || []
          extensions = []

          extensions << "In-seat power & USB outlets" if extensions_array[POWER_USB]
          extensions << "Wi-Fi" if extensions_array[WIFI]
          extensions << "Average legroom (#{segment[LEGROOM]})" if segment[LEGROOM]

          extensions
        end
      end
    end
  end
end
```

**Usage:**
```ruby
# Before (ugly)
price_cents = flight_info[22][7]
price_brl = (price_cents / 100.0).round(2)

# After (clean)
price_brl = FlightInfoMapper.extract_price(flight_info)
```

---

### 3. Strategy Pattern

**Purpose:** Handle different response section types with different strategies.

**Benefits:**
- Open/closed principle (open for extension, closed for modification)
- Easy to add new section types
- Testable strategies in isolation

**Implementation:**

```ruby
# lib/parsers/section_parser.rb
module GoogleFlights
  module Parsers
    class SectionParser
      def self.parse(section_data, section_index)
        strategy = strategy_for(section_index)
        strategy.parse(section_data)
      end

      def self.strategy_for(index)
        case index
        when 2..10
          FlightSectionStrategy.new
        when 17
          AlternativeFlightsSectionStrategy.new
        else
          NullStrategy.new
        end
      end
    end

    # Strategy for main flight sections (indices 2-10)
    class FlightSectionStrategy
      def parse(section_data)
        return [] unless section_data.is_a?(Array)

        section_data.flat_map do |group|
          extract_flights_from_group(group)
        end.compact
      end

      private

      def extract_flights_from_group(group)
        return nil unless group.is_a?(Array) && group[0].is_a?(Array)

        flight_info = group[0][0]
        mapped_data = FlightInfoMapper.map(flight_info)

        return nil unless mapped_data

        Models::Flight.new(**mapped_data)
      end
    end

    # Strategy for alternative flights section
    class AlternativeFlightsSectionStrategy
      def parse(section_data)
        # Handle alternative flights differently if needed
        []
      end
    end

    # Null object pattern - returns empty array for unknown sections
    class NullStrategy
      def parse(_section_data)
        []
      end
    end
  end
end
```

---

### 4. Builder Pattern

**Purpose:** Construct complex flight objects step by step.

**Benefits:**
- Fluent interface
- Optional parameters
- Validation at build time

**Implementation:**

```ruby
# lib/builders/flight_builder.rb
module GoogleFlights
  module Builders
    class FlightBuilder
      def initialize
        @attributes = {}
      end

      def with_airline(code, name)
        @attributes[:airline_code] = code
        @attributes[:airline] = name
        self
      end

      def with_route(departure_airport, arrival_airport)
        @attributes[:departure_airport] = departure_airport
        @attributes[:arrival_airport] = arrival_airport
        self
      end

      def with_times(departure_time, arrival_time)
        @attributes[:departure_time] = departure_time
        @attributes[:arrival_time] = arrival_time
        self
      end

      def with_price(price)
        @attributes[:price] = price
        self
      end

      def with_duration(minutes)
        @attributes[:duration] = minutes
        self
      end

      def with_stops(count)
        @attributes[:stops] = count
        self
      end

      def with_airplane(model)
        @attributes[:airplane] = model
        self
      end

      def with_flight_number(number)
        @attributes[:flight_number] = number
        self
      end

      def add_segment(segment)
        @attributes[:segments] ||= []
        @attributes[:segments] << segment
        self
      end

      def add_extension(extension)
        @attributes[:extensions] ||= []
        @attributes[:extensions] << extension
        self
      end

      def build
        validate!
        Models::Flight.new(**@attributes)
      end

      private

      def validate!
        required = [:departure_airport, :arrival_airport, :price, :duration]
        missing = required.select { |key| @attributes[key].nil? }

        raise ArgumentError, "Missing required attributes: #{missing.join(', ')}" if missing.any?
      end
    end
  end
end
```

**Usage:**
```ruby
flight = FlightBuilder.new
  .with_airline('LA', 'LATAM')
  .with_route(
    Models::Airport.new(code: 'CGH', name: 'Congonhas'),
    Models::Airport.new(code: 'JPA', name: 'João Pessoa')
  )
  .with_times('2026-02-06T19:40:00-03:00', '2026-02-06T22:50:00-03:00')
  .with_price(1850.0)
  .with_duration(190)
  .with_stops(0)
  .add_extension('Wi-Fi')
  .add_extension('In-seat power')
  .build
```

---

### 5. Repository Pattern

**Purpose:** Separate data access/query logic from business logic.

**Benefits:**
- Clean separation of concerns
- Easy to test
- Reusable queries

**Implementation:**

```ruby
# lib/repositories/flight_repository.rb
module GoogleFlights
  module Repositories
    class FlightRepository
      def initialize(flights)
        @flights = flights
      end

      def all
        @flights
      end

      def find_by_airline(airline_code)
        @flights.select { |flight| flight.airline_code == airline_code }
      end

      def find_direct_flights
        @flights.select(&:direct?)
      end

      def find_with_stops
        @flights.reject(&:direct?)
      end

      def find_cheapest(limit = 5)
        @flights.sort_by(&:price).take(limit)
      end

      def find_fastest(limit = 5)
        @flights.sort_by(&:duration).take(limit)
      end

      def find_by_departure_time(start_hour, end_hour)
        @flights.select do |flight|
          time = Time.parse(flight.departure_time)
          time.hour >= start_hour && time.hour <= end_hour
        end
      end

      def find_by_max_price(max_price)
        @flights.select { |flight| flight.price <= max_price }
      end

      def group_by_airline
        @flights.group_by(&:airline)
      end

      def statistics
        {
          total: @flights.count,
          direct: find_direct_flights.count,
          with_stops: find_with_stops.count,
          average_price: average_price,
          cheapest_price: cheapest_price,
          most_expensive_price: most_expensive_price,
          airlines: @flights.map(&:airline).uniq.sort
        }
      end

      private

      def average_price
        return 0 if @flights.empty?
        (@flights.sum(&:price) / @flights.count.to_f).round(2)
      end

      def cheapest_price
        @flights.map(&:price).min
      end

      def most_expensive_price
        @flights.map(&:price).max
      end
    end
  end
end
```

**Usage:**
```ruby
repo = FlightRepository.new(parsed_flights)

direct = repo.find_direct_flights
cheapest = repo.find_cheapest(3)
morning = repo.find_by_departure_time(6, 12)
budget = repo.find_by_max_price(2000.0)

stats = repo.statistics
# => { total: 10, direct: 5, average_price: 1950.0, ... }
```

---

### 6. Null Object Pattern

**Purpose:** Handle missing/invalid data gracefully without nil checks everywhere.

**Benefits:**
- No nil checks scattered throughout code
- Safer method chaining
- Explicit invalid state

**Implementation:**

```ruby
# lib/models/null_flight.rb
module GoogleFlights
  module Models
    class NullFlight
      def departure_airport
        NullAirport.new
      end

      def arrival_airport
        NullAirport.new
      end

      def price
        0.0
      end

      def duration
        0
      end

      def stops
        0
      end

      def airline
        'Unknown'
      end

      def airline_code
        'N/A'
      end

      def flight_number
        'N/A'
      end

      def departure_time
        nil
      end

      def arrival_time
        nil
      end

      def airplane
        'Unknown'
      end

      def extensions
        []
      end

      def segments
        []
      end

      def direct?
        false
      end

      def valid?
        false
      end

      def to_h
        {
          error: 'Invalid flight data',
          valid: false
        }
      end
    end

    class NullAirport
      def code
        'N/A'
      end

      def name
        'Unknown Airport'
      end

      def to_h
        { code: code, name: name }
      end
    end
  end
end
```

**Usage:**
```ruby
# Before (with nil checks)
if flight && flight.departure_airport && flight.departure_airport.code
  puts flight.departure_airport.code
else
  puts 'N/A'
end

# After (with null object)
puts flight.departure_airport.code  # Always works, returns 'N/A' if invalid
```

---

## Refactored Main Parser

Putting it all together:

```ruby
# lib/google_flights_parser.rb
require_relative 'models/flight'
require_relative 'models/airport'
require_relative 'models/segment'
require_relative 'models/null_flight'
require_relative 'parsers/flight_info_mapper'
require_relative 'parsers/section_parser'
require_relative 'repositories/flight_repository'

module GoogleFlights
  class Parser
    def initialize(response_body)
      @response_body = response_body
    end

    def parse
      {
        status: 'success',
        best_flights: extract_flights.map(&:to_h),
        note: 'Successfully retrieved and parsed flight data from Google Flights'
      }
    rescue => e
      {
        status: 'error',
        error: e.message,
        best_flights: []
      }
    end

    def parse_as_objects
      Repositories::FlightRepository.new(extract_flights)
    end

    private

    def extract_flights
      sections = extract_flight_sections

      sections.flat_map.with_index do |section, index|
        Parsers::SectionParser.parse(section, index + 2)
      end.compact.select(&:valid?)
    end

    def extract_flight_sections
      inner_data = parse_nested_json

      (2..10).map do |idx|
        inner_data[idx]
      end.compact
    end

    def parse_nested_json
      cleaned = clean_response(@response_body)
      json_objects = extract_json_objects(cleaned)
      largest = find_largest_json(json_objects)

      raw_data = JSON.parse(largest)
      JSON.parse(raw_data[0][2])
    end

    def clean_response(body)
      body.sub(/^\)\]\}'\n\n/, '')
    end

    def extract_json_objects(text)
      json_objects = []
      lines = text.lines

      i = 0
      while i < lines.length
        line = lines[i].strip

        if line.empty? || line.match?(/^\d+$/)
          i += 1
          next
        end

        begin
          obj = JSON.parse(line)
          json_objects << obj
        rescue JSON::ParserError
          # Skip invalid lines
        end

        i += 1
      end

      json_objects
    end

    def find_largest_json(objects)
      objects.max_by { |obj| obj.to_s.length }
    end
  end
end
```

**Usage:**
```ruby
# Parse as hashes (backwards compatible)
parser = GoogleFlights::Parser.new(response_body)
result = parser.parse
flights_hash = result[:best_flights]

# Parse as objects (new way)
repo = parser.parse_as_objects
direct = repo.find_direct_flights
cheapest = repo.find_cheapest(5)
```

---

## Benefits Summary

### ✅ Readability

**Before:**
```ruby
price_cents = flight_info[22][7]
airline_names = flight_info[1]
```

**After:**
```ruby
price_brl = FlightInfoMapper.extract_price(flight_info)
airline = FlightInfoMapper.extract_airline_name(flight_info)
```

### ✅ Maintainability

- **Single Responsibility**: Each class has one job
- **DRY**: No repeated array index logic
- **Clear Boundaries**: Easy to understand what each component does

### ✅ Testability

```ruby
# Test mapper in isolation
RSpec.describe FlightInfoMapper do
  it 'extracts price correctly' do
    flight_info = build_flight_info(price_data: [nil, nil, nil, nil, nil, nil, nil, 185000])
    expect(FlightInfoMapper.extract_price(flight_info)).to eq(1850.0)
  end
end

# Test repository queries
RSpec.describe FlightRepository do
  it 'finds direct flights' do
    flights = [
      build_flight(stops: 0),
      build_flight(stops: 1),
      build_flight(stops: 0)
    ]
    repo = FlightRepository.new(flights)
    expect(repo.find_direct_flights.count).to eq(2)
  end
end
```

### ✅ Type Safety (with Sorbet)

```ruby
# typed: strict
class FlightInfoMapper
  extend T::Sig

  sig { params(flight_info: T::Array[T.untyped]).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def self.map(flight_info)
    # ...
  end
end
```

### ✅ Extensibility

Easy to add new features:

```ruby
# Add price filtering
class FlightRepository
  def find_business_class
    @flights.select { |f| f.cabin_class == 'business' }
  end
end

# Add new section type
class PremiumFlightsSectionStrategy
  def parse(section_data)
    # Handle premium flights
  end
end
```

---

## Migration Strategy

### Phase 1: Parallel Implementation (Week 1)

1. Create new directory structure:
   ```
   lib/
     models/
       flight.rb
       airport.rb
       segment.rb
     parsers/
       flight_info_mapper.rb
       section_parser.rb
     builders/
       flight_builder.rb
     repositories/
       flight_repository.rb
   ```

2. Implement new classes alongside old code
3. Keep `google_flights_client.rb` unchanged

### Phase 2: Testing & Validation (Week 2)

1. Add comprehensive tests for new implementation
2. Run both parsers in parallel and compare results:

```ruby
# test/integration/parser_comparison_test.rb
def test_parsers_return_same_results
  old_result = OldParser.new(response).parse
  new_result = NewParser.new(response).parse

  assert_equal old_result[:best_flights].length, 
               new_result[:best_flights].length
  
  # Compare each flight
  old_result[:best_flights].zip(new_result[:best_flights]).each do |old, new|
    assert_equal old[:price], new[:price]
    assert_equal old[:airline], new[:airline]
    # ... more comparisons
  end
end
```

### Phase 3: Gradual Switch (Week 3)

1. Add feature flag:

```ruby
class GoogleFlightsClient
  USE_NEW_PARSER = ENV['USE_NEW_PARSER'] == 'true'

  def parse_response(body)
    if USE_NEW_PARSER
      GoogleFlights::Parser.new(body).parse
    else
      extract_flights(body) # old implementation
    end
  end
end
```

2. Test in production with flag enabled for subset of requests
3. Monitor for errors/differences

### Phase 4: Cleanup (Week 4)

1. Remove old parser code
2. Remove feature flag
3. Update documentation
4. Celebrate! 🎉

---

## Testing Examples

### Unit Tests

```ruby
# test/unit/models/flight_test.rb
RSpec.describe GoogleFlights::Models::Flight do
  describe '#direct?' do
    it 'returns true when stops is 0' do
      flight = build_flight(stops: 0)
      expect(flight.direct?).to be true
    end

    it 'returns false when stops is greater than 0' do
      flight = build_flight(stops: 1)
      expect(flight.direct?).to be false
    end
  end

  describe '#valid?' do
    it 'returns false when required fields are missing' do
      flight = GoogleFlights::Models::Flight.new(
        departure_airport: nil,
        arrival_airport: nil,
        price: nil
      )
      expect(flight.valid?).to be false
    end
  end
end

# test/unit/parsers/flight_info_mapper_test.rb
RSpec.describe GoogleFlights::Parsers::FlightInfoMapper do
  describe '.extract_price' do
    it 'converts cents to BRL' do
      flight_info = Array.new(23)
      flight_info[22] = Array.new(8)
      flight_info[22][7] = 185000

      expect(described_class.extract_price(flight_info)).to eq(1850.0)
    end

    it 'returns nil when price data is missing' do
      flight_info = Array.new(23)
      expect(described_class.extract_price(flight_info)).to be_nil
    end
  end
end
```

### Integration Tests

```ruby
# test/integration/parser_test.rb
RSpec.describe GoogleFlights::Parser do
  let(:sample_response) { File.read('test/fixtures/sample_response.txt') }
  let(:parser) { described_class.new(sample_response) }

  describe '#parse' do
    it 'returns success status' do
      result = parser.parse
      expect(result[:status]).to eq('success')
    end

    it 'parses all flights' do
      result = parser.parse
      expect(result[:best_flights]).not_to be_empty
    end

    it 'filters out invalid flights' do
      result = parser.parse
      result[:best_flights].each do |flight|
        expect(flight[:price]).to be > 0
        expect(flight[:departure_airport][:code]).to match(/^[A-Z]{3}$/)
      end
    end
  end

  describe '#parse_as_objects' do
    it 'returns a FlightRepository' do
      repo = parser.parse_as_objects
      expect(repo).to be_a(GoogleFlights::Repositories::FlightRepository)
    end

    it 'allows querying flights' do
      repo = parser.parse_as_objects
      direct = repo.find_direct_flights
      expect(direct).to all(be_direct)
    end
  end
end
```

---

## Performance Considerations

### Memory Usage

The new implementation creates more objects, but they're typically small and short-lived:

```ruby
# Benchmark
require 'benchmark/ips'

Benchmark.ips do |x|
  x.report("old parser") { old_parser.parse(response) }
  x.report("new parser") { new_parser.parse(response) }
  x.compare!
end
```

### Optimization Tips

1. **Use `freeze` for immutable objects**:
   ```ruby
   class Flight
     def initialize(**attrs)
       @price = attrs[:price]
       freeze
     end
   end
   ```

2. **Lazy evaluation for expensive operations**:
   ```ruby
   class Flight
     def segments
       @segments ||= SegmentMapper.map(@raw_segments)
     end
   end
   ```

3. **Memoization for repository queries**:
   ```ruby
   class FlightRepository
     def find_direct_flights
       @direct_flights ||= @flights.select(&:direct?)
     end
   end
   ```

---

## Conclusion

While the refactoring adds more files and classes, the benefits far outweigh the costs:

- **Maintainable**: Easy to understand and modify
- **Testable**: Each component can be tested in isolation
- **Extensible**: New features are easy to add
- **Robust**: Better error handling and validation
- **Self-documenting**: Code clearly expresses intent

The migration can be done gradually with low risk using feature flags and parallel testing.
