# Rails API Integration

## Overview

This document describes how to integrate the Google Flights client into a Rails API with production-ready features including Swagger/OpenAPI documentation, authentication, rate limiting, error handling, and caching.

## Table of Contents

- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [API Endpoints](#api-endpoints)
- [Controllers](#controllers)
- [Services](#services)
- [Serializers](#serializers)
- [Error Handling](#error-handling)
- [Authentication](#authentication)
- [Rate Limiting](#rate-limiting)
- [Caching](#caching)
- [Swagger/OpenAPI](#swaggeropenapi)
- [Testing](#testing)
- [Deployment](#deployment)

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                   API Layer                          │
│                                                       │
│  ┌──────────────┐    ┌──────────────┐               │
│  │ Controllers  │───▶│  Services    │               │
│  │ - Validation │    │ - Business   │               │
│  │ - Auth       │    │   Logic      │               │
│  └──────────────┘    └──────┬───────┘               │
│                              │                        │
│                              ▼                        │
│                    ┌──────────────────┐              │
│                    │ GoogleFlights    │              │
│                    │ Client (lib/)    │              │
│                    └──────────────────┘              │
│                                                       │
└───────────────────────────────────────────────────────┘
           │                    │
           ▼                    ▼
    ┌──────────┐        ┌──────────────┐
    │  Redis   │        │ TokenManager │
    │  Cache   │        │  (Ferrum)    │
    └──────────┘        └──────────────┘
```

## Project Structure

```
app/
├── controllers/
│   └── api/
│       └── v1/
│           ├── flights_controller.rb
│           ├── health_controller.rb
│           └── tokens_controller.rb
├── services/
│   └── flights/
│       ├── search_service.rb
│       ├── price_tracker_service.rb
│       └── error_handler.rb
├── serializers/
│   └── flight_serializer.rb
├── models/
│   └── concerns/
│       └── api_authenticatable.rb
└── middleware/
    ├── rate_limiter.rb
    └── request_logger.rb

config/
├── initializers/
│   ├── swagger.rb
│   ├── rack_attack.rb
│   └── flights_client.rb
└── routes.rb

lib/
├── google_flights_client.rb
├── token_manager.rb
├── browser_token_extractor.rb
└── config/
    ├── token_config.rb
    ├── anti_detection_config.rb
    └── proxy_config.rb
```

## Setup & Installation

### 1. Gemfile

```ruby
# filepath: Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 7.1'
gem 'puma', '~> 6.0'

# API
gem 'rack-cors'
gem 'rack-attack'
gem 'jbuilder'

# Serialization
gem 'active_model_serializers', '~> 0.10.0'
gem 'oj' # Fast JSON

# API Documentation
gem 'rswag'
gem 'rswag-api'
gem 'rswag-ui'

# Authentication
gem 'jwt'
gem 'bcrypt', '~> 3.1.7'

# Caching
gem 'redis', '~> 5.0'
gem 'hiredis'

# Browser automation for tokens
gem 'ferrum'

# Background jobs (for async operations)
gem 'sidekiq'

# Monitoring
gem 'newrelic_rpm'
gem 'sentry-ruby'
gem 'sentry-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rswag-specs'
end

group :test do
  gem 'shoulda-matchers'
  gem 'webmock'
  gem 'vcr'
  gem 'simplecov'
end
```

### 2. Initialize Swagger

```bash
rails g rswag:install
rails g rswag:api:install
rails g rswag:ui:install
```

### 3. Configure Routes

```ruby
# filepath: config/routes.rb
Rails.application.routes.draw do
  # Swagger/OpenAPI documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      # Flight search endpoints
      resources :flights, only: [] do
        collection do
          get :search
          get :price_history
        end
      end

      # Health checks
      get 'health', to: 'health#show'
      get 'health/tokens', to: 'health#tokens'

      # Token management (admin only)
      resource :tokens, only: [] do
        post :refresh
        get :status
      end
    end
  end

  # API versioning fallback
  namespace :api, defaults: { format: :json } do
    match '*path', to: 'base#not_found', via: :all
  end
end
```

## API Endpoints

### Flight Search

**Endpoint:** `GET /api/v1/flights/search`

**Query Parameters:**
- `origin` (required) - IATA airport code (e.g., "CGH")
- `destination` (required) - IATA airport code (e.g., "JPA")
- `departure_date` (required) - Date in YYYY-MM-DD format
- `return_date` (required) - Date in YYYY-MM-DD format
- `adults` (optional) - Number of adult passengers (default: 1)
- `children` (optional) - Number of children (default: 0)
- `infants` (optional) - Number of infants (default: 0)
- `cabin_class` (optional) - "economy", "premium", "business", "first" (default: "economy")

**Response:** `200 OK`

```json
{
  "data": [
    {
      "id": "flight-1",
      "type": "flight",
      "attributes": {
        "airline": "LATAM",
        "flight_number": "LA1234",
        "departure_time": "06:00",
        "arrival_time": "08:30",
        "duration": "2h 30m",
        "stops": 0,
        "price": 450.50,
        "currency": "BRL",
        "emissions": "120 kg CO₂e",
        "aircraft": "Airbus A320",
        "departure_airport": {
          "code": "CGH",
          "name": "Congonhas",
          "city": "São Paulo"
        },
        "arrival_airport": {
          "code": "JPA",
          "name": "Castro Pinto",
          "city": "João Pessoa"
        }
      }
    }
  ],
  "meta": {
    "total": 15,
    "search_params": {
      "origin": "CGH",
      "destination": "JPA",
      "departure_date": "2026-02-06",
      "return_date": "2026-02-27"
    },
    "cached": false,
    "response_time_ms": 1250
  }
}
```

### Health Check

**Endpoint:** `GET /api/v1/health`

**Response:** `200 OK`

```json
{
  "status": "ok",
  "timestamp": "2025-12-10T15:30:00Z",
  "services": {
    "database": "ok",
    "redis": "ok",
    "flights_api": "ok"
  }
}
```

### Token Status

**Endpoint:** `GET /api/v1/health/tokens`

**Response:** `200 OK`

```json
{
  "status": "ok",
  "expired": false,
  "last_refreshed_at": "2025-12-10T10:00:00Z",
  "ttl_remaining_seconds": 82800,
  "ttl_remaining_hours": 23.0
}
```

## Controllers

### Base Controller

```ruby
# filepath: app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler

      before_action :authenticate_request!
      before_action :set_default_format

      rescue_from StandardError, with: :handle_standard_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

      private

      def set_default_format
        request.format = :json
      end

      def authenticate_request!
        return if valid_api_key?

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def valid_api_key?
        # Skip auth for health checks in development
        return true if Rails.env.development? && controller_name == 'health'

        api_key = request.headers['X-API-Key']
        return false unless api_key

        # Validate against stored API keys
        ApiKey.exists?(key: api_key, active: true)
      end

      def current_user
        @current_user ||= begin
          token = request.headers['Authorization']&.split(' ')&.last
          decoded = JWT.decode(token, Rails.application.credentials.secret_key_base).first
          User.find(decoded['user_id'])
        rescue
          nil
        end
      end
    end
  end
end
```

### Flights Controller

```ruby
# filepath: app/controllers/api/v1/flights_controller.rb
module Api
  module V1
    class FlightsController < BaseController
      # GET /api/v1/flights/search
      def search
        validate_search_params!

        result = Flights::SearchService.new(search_params).call

        if result.success?
          render json: result.data, 
                 serializer: FlightSearchSerializer,
                 meta: result.metadata,
                 status: :ok
        else
          render json: { error: result.error }, 
                 status: result.status
        end
      end

      # GET /api/v1/flights/price_history
      def price_history
        validate_price_history_params!

        result = Flights::PriceTrackerService.new(price_history_params).call

        if result.success?
          render json: result.data, status: :ok
        else
          render json: { error: result.error }, status: result.status
        end
      end

      private

      def search_params
        params.permit(
          :origin,
          :destination,
          :departure_date,
          :return_date,
          :adults,
          :children,
          :infants,
          :cabin_class
        )
      end

      def price_history_params
        params.permit(:origin, :destination, :departure_date, :days)
      end

      def validate_search_params!
        required = [:origin, :destination, :departure_date, :return_date]
        missing = required - params.keys.map(&:to_sym)

        if missing.any?
          raise ActionController::ParameterMissing, 
                "Missing parameters: #{missing.join(', ')}"
        end

        validate_date_format!(:departure_date)
        validate_date_format!(:return_date)
        validate_airport_code!(:origin)
        validate_airport_code!(:destination)
      end

      def validate_price_history_params!
        required = [:origin, :destination, :departure_date]
        missing = required - params.keys.map(&:to_sym)

        if missing.any?
          raise ActionController::ParameterMissing, 
                "Missing parameters: #{missing.join(', ')}"
        end
      end

      def validate_date_format!(param)
        Date.parse(params[param])
      rescue ArgumentError
        raise ActionController::BadRequest, 
              "Invalid date format for #{param}. Use YYYY-MM-DD"
      end

      def validate_airport_code!(param)
        code = params[param]
        unless code.match?(/\A[A-Z]{3}\z/)
          raise ActionController::BadRequest,
                "Invalid airport code for #{param}. Use 3-letter IATA code"
        end
      end
    end
  end
end
```

### Health Controller

```ruby
# filepath: app/controllers/api/v1/health_controller.rb
module Api
  module V1
    class HealthController < BaseController
      skip_before_action :authenticate_request!

      # GET /api/v1/health
      def show
        services = {
          database: check_database,
          redis: check_redis,
          flights_api: check_flights_api
        }

        status = services.values.all? { |s| s == 'ok' } ? 'ok' : 'degraded'

        render json: {
          status: status,
          timestamp: Time.current.iso8601,
          services: services
        }, status: status == 'ok' ? :ok : :service_unavailable
      end

      # GET /api/v1/health/tokens
      def tokens
        manager = GoogleFlights::TokenManager.instance

        render json: {
          status: manager.tokens_expired? ? 'expired' : 'ok',
          expired: manager.tokens_expired?,
          last_refreshed_at: manager.last_refreshed_at&.iso8601,
          ttl_remaining_seconds: manager.ttl_remaining.to_i,
          ttl_remaining_hours: (manager.ttl_remaining / 3600).round(2)
        }
      rescue => e
        render json: {
          status: 'error',
          error: e.message
        }, status: :service_unavailable
      end

      private

      def check_database
        ActiveRecord::Base.connection.execute('SELECT 1')
        'ok'
      rescue
        'error'
      end

      def check_redis
        Redis.current.ping == 'PONG' ? 'ok' : 'error'
      rescue
        'error'
      end

      def check_flights_api
        # Simple token check
        GoogleFlights::TokenManager.instance.tokens.present? ? 'ok' : 'error'
      rescue
        'error'
      end
    end
  end
end
```

### Tokens Controller

```ruby
# filepath: app/controllers/api/v1/tokens_controller.rb
module Api
  module V1
    class TokensController < BaseController
      before_action :require_admin!

      # POST /api/v1/tokens/refresh
      def refresh
        manager = GoogleFlights::TokenManager.instance
        manager.refresh_tokens!

        render json: {
          message: 'Tokens refreshed successfully',
          last_refreshed_at: manager.last_refreshed_at.iso8601,
          ttl_remaining_hours: (manager.ttl_remaining / 3600).round(2)
        }, status: :ok
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/tokens/status
      def status
        manager = GoogleFlights::TokenManager.instance

        render json: {
          expired: manager.tokens_expired?,
          last_refreshed_at: manager.last_refreshed_at&.iso8601,
          ttl_remaining_seconds: manager.ttl_remaining.to_i,
          ttl_remaining_hours: (manager.ttl_remaining / 3600).round(2),
          tokens_present: manager.tokens.present?
        }
      end

      private

      def require_admin!
        unless current_user&.admin?
          render json: { error: 'Admin access required' }, status: :forbidden
        end
      end
    end
  end
end
```

## Services

### Search Service

```ruby
# filepath: app/services/flights/search_service.rb
module Flights
  class SearchService
    include ErrorHandler

    def initialize(params)
      @params = params
      @client = GoogleFlights::Client.instance
    end

    def call
      start_time = Time.current

      # Check cache first
      cached_result = fetch_from_cache
      return cached_result if cached_result

      # Make API request
      flights = search_flights
      
      response_time = ((Time.current - start_time) * 1000).round

      # Cache successful results
      cache_result(flights) if flights.any?

      ServiceResult.success(
        data: flights,
        metadata: build_metadata(flights.size, response_time, cached: false)
      )
    rescue GoogleFlights::TokenExtractionError => e
      Rails.logger.error "[FlightsSearch] Token extraction failed: #{e.message}"
      ServiceResult.error(
        error: 'Service temporarily unavailable. Please try again later.',
        status: :service_unavailable
      )
    rescue => e
      Rails.logger.error "[FlightsSearch] Search failed: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      
      ServiceResult.error(
        error: 'Failed to search flights',
        status: :internal_server_error
      )
    end

    private

    def search_flights
      result = @client.search(
        origin: @params[:origin],
        destination: @params[:destination],
        departure_date: @params[:departure_date],
        return_date: @params[:return_date]
      )

      result[:flights] || []
    end

    def fetch_from_cache
      cache_key = build_cache_key
      cached = Rails.cache.read(cache_key)

      if cached
        Rails.logger.info "[FlightsSearch] Cache hit: #{cache_key}"
        ServiceResult.success(
          data: cached[:flights],
          metadata: build_metadata(cached[:flights].size, 0, cached: true)
        )
      else
        Rails.logger.info "[FlightsSearch] Cache miss: #{cache_key}"
        nil
      end
    end

    def cache_result(flights)
      cache_key = build_cache_key
      Rails.cache.write(
        cache_key,
        { flights: flights, cached_at: Time.current },
        expires_in: 1.hour
      )
    end

    def build_cache_key
      "flights:search:#{@params[:origin]}:#{@params[:destination]}:" \
      "#{@params[:departure_date]}:#{@params[:return_date]}"
    end

    def build_metadata(total, response_time, cached:)
      {
        total: total,
        search_params: @params.slice(:origin, :destination, :departure_date, :return_date),
        cached: cached,
        response_time_ms: response_time
      }
    end
  end

  # Service result object
  class ServiceResult
    attr_reader :data, :metadata, :error, :status

    def initialize(success:, data: nil, metadata: {}, error: nil, status: :ok)
      @success = success
      @data = data
      @metadata = metadata
      @error = error
      @status = status
    end

    def success?
      @success
    end

    def self.success(data:, metadata: {})
      new(success: true, data: data, metadata: metadata)
    end

    def self.error(error:, status: :internal_server_error)
      new(success: false, error: error, status: status)
    end
  end
end
```

### Price Tracker Service

```ruby
# filepath: app/services/flights/price_tracker_service.rb
module Flights
  class PriceTrackerService
    def initialize(params)
      @params = params
      @days = (params[:days] || 7).to_i
      @client = GoogleFlights::Client.instance
    end

    def call
      price_history = []
      base_date = Date.parse(@params[:departure_date])

      @days.times do |offset|
        departure = base_date + offset.days
        return_date = departure + 7.days

        flights = fetch_flights(departure, return_date)
        
        if flights.any?
          price_history << {
            date: departure.to_s,
            min_price: flights.map { |f| f[:price] }.min,
            avg_price: (flights.map { |f| f[:price] }.sum / flights.size).round(2),
            max_price: flights.map { |f| f[:price] }.max,
            flight_count: flights.size
          }
        end

        # Rate limiting
        sleep(0.5) unless offset == @days - 1
      end

      ServiceResult.success(
        data: {
          origin: @params[:origin],
          destination: @params[:destination],
          price_history: price_history
        }
      )
    rescue => e
      Rails.logger.error "[PriceTracker] Failed: #{e.message}"
      ServiceResult.error(
        error: 'Failed to fetch price history',
        status: :internal_server_error
      )
    end

    private

    def fetch_flights(departure, return_date)
      result = @client.search(
        origin: @params[:origin],
        destination: @params[:destination],
        departure_date: departure.to_s,
        return_date: return_date.to_s
      )

      result[:flights] || []
    end
  end
end
```

### Error Handler

```ruby
# filepath: app/services/flights/error_handler.rb
module Flights
  module ErrorHandler
    extend ActiveSupport::Concern

    included do
      rescue_from StandardError, with: :handle_standard_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
      rescue_from ActionController::BadRequest, with: :handle_bad_request
    end

    private

    def handle_standard_error(exception)
      log_error(exception)
      
      render json: {
        error: 'Internal server error',
        message: Rails.env.production? ? 'Something went wrong' : exception.message
      }, status: :internal_server_error
    end

    def handle_not_found(exception)
      render json: {
        error: 'Not found',
        message: exception.message
      }, status: :not_found
    end

    def handle_parameter_missing(exception)
      render json: {
        error: 'Missing parameter',
        message: exception.message
      }, status: :bad_request
    end

    def handle_bad_request(exception)
      render json: {
        error: 'Bad request',
        message: exception.message
      }, status: :bad_request
    end

    def log_error(exception)
      Rails.logger.error "[#{controller_name}] #{exception.class}: #{exception.message}"
      Rails.logger.error exception.backtrace.first(10).join("\n")
      
      # Send to error tracking service
      Sentry.capture_exception(exception) if defined?(Sentry)
    end
  end
end
```

## Serializers

### Flight Serializer

```ruby
# filepath: app/serializers/flight_serializer.rb
class FlightSerializer < ActiveModel::Serializer
  attributes :id, :airline, :flight_number, :departure_time, :arrival_time,
             :duration, :stops, :price, :currency, :emissions, :aircraft,
             :departure_airport, :arrival_airport

  def id
    "flight-#{object[:flight_number]}-#{object[:departure_time]}"
  end

  def departure_airport
    {
      code: extract_airport_code(object[:route], 0),
      name: 'Airport Name', # Could be enhanced with airport data lookup
      city: 'City Name'
    }
  end

  def arrival_airport
    {
      code: extract_airport_code(object[:route], 1),
      name: 'Airport Name',
      city: 'City Name'
    }
  end

  private

  def extract_airport_code(route, index)
    route&.split(' → ')&.[](index) || 'Unknown'
  end
end
```

### Flight Search Serializer

```ruby
# filepath: app/serializers/flight_search_serializer.rb
class FlightSearchSerializer < ActiveModel::Serializer
  attributes :data, :meta

  def data
    object.map do |flight|
      FlightSerializer.new(flight).attributes
    end
  end

  def meta
    instance_options[:meta] || {}
  end
end
```

## Error Handling

### Custom Error Classes

```ruby
# filepath: app/errors/flights_api_error.rb
module FlightsApiError
  class Base < StandardError
    attr_reader :status, :code

    def initialize(message = nil, status: :internal_server_error, code: nil)
      super(message)
      @status = status
      @code = code
    end
  end

  class TokenExpired < Base
    def initialize(message = 'API tokens expired')
      super(message, status: :service_unavailable, code: 'TOKEN_EXPIRED')
    end
  end

  class RateLimitExceeded < Base
    def initialize(message = 'Rate limit exceeded')
      super(message, status: :too_many_requests, code: 'RATE_LIMIT_EXCEEDED')
    end
  end

  class InvalidParameters < Base
    def initialize(message = 'Invalid parameters')
      super(message, status: :bad_request, code: 'INVALID_PARAMETERS')
    end
  end
end
```

## Authentication

### API Key Model

```ruby
# filepath: app/models/api_key.rb
class ApiKey < ApplicationRecord
  belongs_to :user, optional: true

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  before_validation :generate_key, on: :create

  scope :active, -> { where(active: true) }

  def self.authenticate(key)
    active.find_by(key: key)
  end

  private

  def generate_key
    self.key ||= SecureRandom.hex(32)
  end
end

# Migration
# rails g migration CreateApiKeys user:references name:string key:string:index active:boolean last_used_at:datetime
```

### JWT Authentication

```ruby
# filepath: app/services/auth/json_web_token.rb
module Auth
  class JsonWebToken
    SECRET_KEY = Rails.application.credentials.secret_key_base

    def self.encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
      decoded = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError => e
      nil
    end
  end
end
```

## Rate Limiting

### Rack Attack Configuration

```ruby
# filepath: config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle all requests by IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/api/v1/health')
  end

  # Throttle API endpoint by IP
  throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api/v1/flights')
  end

  # Throttle API by API key
  throttle('api/key', limit: 1000, period: 1.hour) do |req|
    if req.path.start_with?('/api/v1/flights')
      req.env['HTTP_X_API_KEY']
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = env['rack.attack.match_data'][:period]
    
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{
        error: 'Rate limit exceeded',
        retry_after_seconds: retry_after
      }.to_json]
    ]
  end
end

# Enable in production
Rails.application.config.middleware.use Rack::Attack if Rails.env.production?
```

## Caching

### Redis Configuration

```ruby
# filepath: config/initializers/redis.rb
Redis.current = Redis.new(
  url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
  driver: :hiredis,
  reconnect_attempts: 3,
  timeout: 5
)

# Cache store
Rails.application.config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
  expires_in: 1.hour,
  namespace: 'flights_api',
  pool_size: 5,
  pool_timeout: 5
}
```

### Cache Strategies

```ruby
# filepath: app/services/flights/cache_strategy.rb
module Flights
  class CacheStrategy
    class << self
      # Multi-tier caching: Redis -> Memory
      def fetch(key, expires_in: 1.hour, &block)
        # Try memory cache first
        memory_result = memory_cache.read(key)
        return memory_result if memory_result

        # Try Redis cache
        redis_result = Rails.cache.fetch(key, expires_in: expires_in, &block)
        
        # Store in memory for faster access
        memory_cache.write(key, redis_result, expires_in: 5.minutes)
        
        redis_result
      end

      def invalidate(pattern)
        # Clear from both caches
        memory_cache.clear
        Redis.current.keys(pattern).each { |key| Redis.current.del(key) }
      end

      private

      def memory_cache
        @memory_cache ||= ActiveSupport::Cache::MemoryStore.new
      end
    end
  end
end
```

## Swagger/OpenAPI

### Swagger Configuration

```ruby
# filepath: config/initializers/swagger.rb
Rswag::Api.configure do |c|
  c.swagger_root = Rails.root.join('swagger').to_s
  c.swagger_filter = lambda { |swagger, env| swagger }
end

Rswag::Ui.configure do |c|
  c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'
  c.config_object = {
    deepLinking: true,
    displayRequestDuration: true,
    docExpansion: 'list',
    filter: true,
    showExtensions: true,
    tryItOutEnabled: true
  }
end
```

### Swagger Specification

```ruby
# filepath: spec/requests/api/v1/flights_spec.rb
require 'swagger_helper'

RSpec.describe 'api/v1/flights', type: :request do
  path '/api/v1/flights/search' do
    get 'Search for flights' do
      tags 'Flights'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: 'X-API-Key', in: :header, type: :string, required: true,
                description: 'API authentication key'
      parameter name: :origin, in: :query, type: :string, required: true,
                description: 'Origin airport IATA code (e.g., CGH)'
      parameter name: :destination, in: :query, type: :string, required: true,
                description: 'Destination airport IATA code (e.g., JPA)'
      parameter name: :departure_date, in: :query, type: :string, required: true,
                description: 'Departure date (YYYY-MM-DD)'
      parameter name: :return_date, in: :query, type: :string, required: true,
                description: 'Return date (YYYY-MM-DD)'
      parameter name: :adults, in: :query, type: :integer, required: false,
                description: 'Number of adults (default: 1)'
      parameter name: :cabin_class, in: :query, type: :string, required: false,
                description: 'Cabin class: economy, premium, business, first'

      response '200', 'Flights found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: {
                         type: :object,
                         properties: {
                           airline: { type: :string },
                           flight_number: { type: :string },
                           departure_time: { type: :string },
                           arrival_time: { type: :string },
                           duration: { type: :string },
                           stops: { type: :integer },
                           price: { type: :number },
                           currency: { type: :string },
                           emissions: { type: :string },
                           departure_airport: {
                             type: :object,
                             properties: {
                               code: { type: :string },
                               name: { type: :string },
                               city: { type: :string }
                             }
                           },
                           arrival_airport: {
                             type: :object,
                             properties: {
                               code: { type: :string },
                               name: { type: :string },
                               city: { type: :string }
                             }
                           }
                         }
                       }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     total: { type: :integer },
                     cached: { type: :boolean },
                     response_time_ms: { type: :integer }
                   }
                 }
               }

        let('X-API-Key') { 'valid_api_key' }
        let(:origin) { 'CGH' }
        let(:destination) { 'JPA' }
        let(:departure_date) { '2026-02-06' }
        let(:return_date) { '2026-02-27' }

        run_test!
      end

      response '400', 'Bad request' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 message: { type: :string }
               }

        let('X-API-Key') { 'valid_api_key' }
        let(:origin) { 'INVALID' }
        let(:destination) { 'JPA' }
        let(:departure_date) { '2026-02-06' }
        let(:return_date) { '2026-02-27' }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let('X-API-Key') { 'invalid_key' }
        let(:origin) { 'CGH' }
        let(:destination) { 'JPA' }
        let(:departure_date) { '2026-02-06' }
        let(:return_date) { '2026-02-27' }

        run_test!
      end

      response '429', 'Rate limit exceeded' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 retry_after_seconds: { type: :integer }
               }

        let('X-API-Key') { 'valid_api_key' }
        let(:origin) { 'CGH' }
        let(:destination) { 'JPA' }
        let(:departure_date) { '2026-02-06' }
        let(:return_date) { '2026-02-27' }

        run_test!
      end
    end
  end
end
```

### Generate Swagger Docs

```bash
# Generate swagger documentation
rake rswag:specs:swaggerize

# View at http://localhost:3000/api-docs
```

## Testing

### Controller Specs

```ruby
# filepath: spec/requests/api/v1/flights_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::FlightsController, type: :request do
  let(:api_key) { create(:api_key, active: true) }
  let(:headers) { { 'X-API-Key' => api_key.key } }

  describe 'GET /api/v1/flights/search' do
    let(:valid_params) do
      {
        origin: 'CGH',
        destination: 'JPA',
        departure_date: '2026-02-06',
        return_date: '2026-02-27'
      }
    end

    context 'with valid parameters' do
      before do
        allow_any_instance_of(Flights::SearchService)
          .to receive(:call)
          .and_return(service_success_result)
      end

      it 'returns flights' do
        get '/api/v1/flights/search', params: valid_params, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).to be_an(Array)
        expect(json['meta']).to be_present
      end

      it 'caches the result' do
        expect(Rails.cache).to receive(:write)
        get '/api/v1/flights/search', params: valid_params, headers: headers
      end
    end

    context 'with missing parameters' do
      it 'returns bad request' do
        get '/api/v1/flights/search', 
            params: valid_params.except(:origin), 
            headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with invalid API key' do
      it 'returns unauthorized' do
        get '/api/v1/flights/search', 
            params: valid_params, 
            headers: { 'X-API-Key' => 'invalid' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  def service_success_result
    Flights::ServiceResult.success(
      data: [
        { airline: 'LATAM', flight_number: 'LA1234', price: 450.50 }
      ],
      metadata: { total: 1, cached: false }
    )
  end
end
```

### Service Specs

```ruby
# filepath: spec/services/flights/search_service_spec.rb
require 'rails_helper'

RSpec.describe Flights::SearchService do
  let(:params) do
    {
      origin: 'CGH',
      destination: 'JPA',
      departure_date: '2026-02-06',
      return_date: '2026-02-27'
    }
  end

  let(:client) { instance_double(GoogleFlights::Client) }

  before do
    allow(GoogleFlights::Client).to receive(:instance).and_return(client)
  end

  describe '#call' do
    context 'with successful API response' do
      let(:api_response) do
        {
          flights: [
            { airline: 'LATAM', price: 450.50 },
            { airline: 'GOL', price: 380.00 }
          ]
        }
      end

      before do
        allow(client).to receive(:search).and_return(api_response)
      end

      it 'returns success result' do
        result = described_class.new(params).call

        expect(result).to be_success
        expect(result.data.size).to eq(2)
        expect(result.metadata[:total]).to eq(2)
      end

      it 'caches the result' do
        expect(Rails.cache).to receive(:write)
        described_class.new(params).call
      end
    end

    context 'when cache hit' do
      before do
        Rails.cache.write(
          "flights:search:CGH:JPA:2026-02-06:2026-02-27",
          { flights: [{ airline: 'LATAM' }] }
        )
      end

      it 'returns cached data without API call' do
        expect(client).not_to receive(:search)
        
        result = described_class.new(params).call
        expect(result).to be_success
        expect(result.metadata[:cached]).to be true
      end
    end

    context 'with API error' do
      before do
        allow(client).to receive(:search).and_raise(StandardError, 'API error')
      end

      it 'returns error result' do
        result = described_class.new(params).call

        expect(result).not_to be_success
        expect(result.error).to be_present
      end
    end
  end
end
```

## Deployment

### Environment Configuration

```bash
# filepath: .env.production
RAILS_ENV=production
RACK_ENV=production

# Database
DATABASE_URL=postgresql://user:password@localhost/flights_api_production

# Redis
REDIS_URL=redis://localhost:6379/0

# Token Management
TOKEN_TTL=86400
BROWSER_POOL_SIZE=5
AUTO_REFRESH_TOKENS=true
TOKEN_CACHE_PATH=/var/cache/flights-api/tokens.json

# Anti-Detection
USE_PROXY=true
PROXY_ROTATION=true
RANDOMIZE_USER_AGENT=true

# API Keys
SECRET_KEY_BASE=your_secret_key_here

# Monitoring
SENTRY_DSN=https://your-sentry-dsn
NEWRELIC_LICENSE_KEY=your_newrelic_key

# Rate Limiting
RACK_ATTACK_ENABLED=true
```

### Docker Setup

```dockerfile
# filepath: Dockerfile
FROM ruby:3.2-slim

# Install Chrome for Ferrum
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y \
       google-chrome-stable \
       postgresql-client \
       libpq-dev \
       build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

# Precompile assets (if using asset pipeline)
RUN bundle exec rails assets:precompile

# Create cache directory
RUN mkdir -p /var/cache/flights-api

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

### Docker Compose

```yaml
# filepath: docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/flights_api_production
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - token-cache:/var/cache/flights-api

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: flights_api_production
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data

  sidekiq:
    build: .
    command: bundle exec sidekiq
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/flights_api_production
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis

volumes:
  postgres-data:
  redis-data:
  token-cache:
```

### Monitoring

```ruby
# filepath: config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.5
  config.environment = Rails.env
  config.enabled_environments = %w[production staging]
end
```

### Performance Monitoring

```ruby
# filepath: config/initializers/newrelic.rb
# newrelic.yml is automatically loaded

# Custom instrumentation
class ApplicationController < ActionController::API
  around_action :trace_request

  private

  def trace_request
    ::NewRelic::Agent.notice_error(exception) if exception
    yield
  ensure
    ::NewRelic::Agent.increment_metric('Custom/API/Request')
  end
end
```

## Production Checklist

- [ ] API authentication configured (API keys or JWT)
- [ ] Rate limiting enabled with Rack::Attack
- [ ] Redis caching configured
- [ ] Error tracking setup (Sentry)
- [ ] Performance monitoring (New Relic)
- [ ] Swagger documentation generated
- [ ] Health check endpoints working
- [ ] Database connection pooling configured
- [ ] Background jobs setup (Sidekiq)
- [ ] Token management system initialized
- [ ] Browser pool configured appropriately
- [ ] Anti-detection measures enabled
- [ ] CORS configured for allowed origins
- [ ] SSL/TLS enabled
- [ ] Database backups configured
- [ ] Log aggregation setup
- [ ] Monitoring alerts configured
- [ ] Load balancer configured (if multi-server)

## API Usage Examples

### cURL

```bash
# Search for flights
curl -X GET "http://localhost:3000/api/v1/flights/search?origin=CGH&destination=JPA&departure_date=2026-02-06&return_date=2026-02-27" \
  -H "X-API-Key: your_api_key"

# Health check
curl -X GET "http://localhost:3000/api/v1/health"

# Token status
curl -X GET "http://localhost:3000/api/v1/health/tokens"
```

### JavaScript

```javascript
// Using fetch
const searchFlights = async () => {
  const params = new URLSearchParams({
    origin: 'CGH',
    destination: 'JPA',
    departure_date: '2026-02-06',
    return_date: '2026-02-27'
  });

  const response = await fetch(
    `https://api.example.com/api/v1/flights/search?${params}`,
    {
      headers: {
        'X-API-Key': 'your_api_key'
      }
    }
  );

  const data = await response.json();
  return data;
};
```

### Python

```python
import requests

def search_flights(origin, destination, departure_date, return_date):
    url = 'https://api.example.com/api/v1/flights/search'
    params = {
        'origin': origin,
        'destination': destination,
        'departure_date': departure_date,
        'return_date': return_date
    }
    headers = {
        'X-API-Key': 'your_api_key'
    }
    
    response = requests.get(url, params=params, headers=headers)
    return response.json()

# Usage
flights = search_flights('CGH', 'JPA', '2026-02-06', '2026-02-27')
```

## References

- [Rails API Mode](https://guides.rubyonrails.org/api_app.html)
- [Rswag Documentation](https://github.com/rswag/rswag)
- [Rack::Attack](https://github.com/rack/rack-attack)
- [Active Model Serializers](https://github.com/rails-api/active_model_serializers)
- [Redis with Rails](https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-rediscachestore)
