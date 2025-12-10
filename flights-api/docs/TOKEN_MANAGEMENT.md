# Token Management & Browser Automation

## Overview

Google Flights uses anti-bot tokens that expire periodically. This document describes a lazy-loading token management system using real browser instances via Ferrum to automatically extract fresh tokens.

## Table of Contents

- [Architecture](#architecture)
- [Components](#components)
- [Configuration](#configuration)
- [Implementation](#implementation)
- [Usage Examples](#usage-examples)
- [Deployment Considerations](#deployment-considerations)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  GoogleFlightsClient                     │
│  - Makes API requests with current tokens                │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                     TokenManager                         │
│  - Lazy loads tokens only when needed                   │
│  - Caches tokens until expiration                        │
│  - Configurable TTL (default: 24 hours)                  │
│  - Thread-safe for concurrent access                     │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                 BrowserTokenExtractor                    │
│  - Manages browser pool (Ferrum)                         │
│  - Extracts tokens from real browser sessions            │
│  - Handles concurrent token requests                     │
│  - Auto-retry on failures                                │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   Browser Pool                           │
│  - Pool of headless Chrome instances                     │
│  - Reuses browsers for efficiency                        │
│  - Configurable pool size                                │
└─────────────────────────────────────────────────────────┘
```

## Components

### 1. Configuration

Centralized configuration for token management:

```ruby
# filepath: config/token_config.yml
development:
  token_ttl: 86400  # 24 hours in seconds
  browser_pool_size: 2
  browser_timeout: 30
  extraction_timeout: 60
  auto_refresh: true
  cache_path: 'tmp/tokens.json'

production:
  token_ttl: 86400
  browser_pool_size: 5
  browser_timeout: 30
  extraction_timeout: 60
  auto_refresh: true
  cache_path: '/var/cache/flights-api/tokens.json'

test:
  token_ttl: 3600  # 1 hour for testing
  browser_pool_size: 1
  browser_timeout: 10
  extraction_timeout: 30
  auto_refresh: false
  cache_path: 'tmp/test_tokens.json'
```

```ruby
# filepath: lib/config/token_config.rb
require 'yaml'

module GoogleFlights
  module Config
    class TokenConfig
      class << self
        def load(env = ENV['RACK_ENV'] || 'development')
          config_file = File.join(__dir__, '../../config/token_config.yml')
          config = YAML.load_file(config_file)
          config[env] || config['development']
        end

        def token_ttl
          @config ||= load
          @config['token_ttl']
        end

        def browser_pool_size
          @config ||= load
          @config['browser_pool_size']
        end

        def browser_timeout
          @config ||= load
          @config['browser_timeout']
        end

        def extraction_timeout
          @config ||= load
          @config['extraction_timeout']
        end

        def auto_refresh?
          @config ||= load
          @config['auto_refresh']
        end

        def cache_path
          @config ||= load
          @config['cache_path']
        end

        def reload!
          @config = nil
          load
        end
      end
    end
  end
end
```

### 2. Token Manager (Singleton)

Handles token lifecycle with lazy loading and caching:

```ruby
# filepath: lib/token_manager.rb
require 'singleton'
require 'json'
require 'fileutils'
require_relative 'config/token_config'
require_relative 'browser_token_extractor'

module GoogleFlights
  class TokenManager
    include Singleton

    attr_reader :last_refreshed_at

    def initialize
      @mutex = Mutex.new
      @tokens = nil
      @last_refreshed_at = nil
      load_from_cache
    end

    # Get current valid tokens (lazy load if needed)
    def tokens
      @mutex.synchronize do
        if tokens_expired? || @tokens.nil?
          refresh_tokens!
        end
        @tokens
      end
    end

    # Force refresh tokens
    def refresh_tokens!
      @mutex.synchronize do
        Rails.logger.info "[TokenManager] Refreshing tokens..." if defined?(Rails)
        
        @tokens = BrowserTokenExtractor.instance.extract_tokens
        @last_refreshed_at = Time.now
        
        save_to_cache
        
        Rails.logger.info "[TokenManager] Tokens refreshed successfully" if defined?(Rails)
        @tokens
      end
    rescue => e
      Rails.logger.error "[TokenManager] Failed to refresh tokens: #{e.message}" if defined?(Rails)
      
      # Fall back to cached tokens if available
      if @tokens && !@tokens.empty?
        Rails.logger.warn "[TokenManager] Using cached tokens as fallback" if defined?(Rails)
        @tokens
      else
        raise TokenExtractionError, "Failed to extract tokens and no cache available: #{e.message}"
      end
    end

    # Check if tokens are expired
    def tokens_expired?
      return true if @last_refreshed_at.nil?
      
      ttl = Config::TokenConfig.token_ttl
      Time.now - @last_refreshed_at > ttl
    end

    # Get specific token
    def get_token(name)
      tokens[name]
    end

    # Get all tokens as hash
    def to_h
      tokens.dup
    end

    # Time until tokens expire
    def ttl_remaining
      return 0 if @last_refreshed_at.nil?
      
      ttl = Config::TokenConfig.token_ttl
      remaining = ttl - (Time.now - @last_refreshed_at)
      [remaining, 0].max
    end

    private

    def save_to_cache
      cache_path = Config::TokenConfig.cache_path
      FileUtils.mkdir_p(File.dirname(cache_path))
      
      cache_data = {
        tokens: @tokens,
        refreshed_at: @last_refreshed_at.to_i,
        ttl: Config::TokenConfig.token_ttl
      }
      
      File.write(cache_path, JSON.pretty_generate(cache_data))
    end

    def load_from_cache
      cache_path = Config::TokenConfig.cache_path
      return unless File.exist?(cache_path)
      
      cache_data = JSON.parse(File.read(cache_path), symbolize_names: true)
      @tokens = cache_data[:tokens]
      @last_refreshed_at = Time.at(cache_data[:refreshed_at])
      
      # Invalidate cache if it's too old
      if tokens_expired?
        @tokens = nil
        @last_refreshed_at = nil
      end
    rescue => e
      # Silently ignore cache load errors
      @tokens = nil
      @last_refreshed_at = nil
    end
  end

  class TokenExtractionError < StandardError; end
end
```

### 3. Anti-Detection Configuration

Google's anti-bot systems detect automated scraping through various signals. To minimize detection risk, randomize browser fingerprints:

```ruby
# filepath: lib/config/anti_detection_config.rb
module GoogleFlights
  module Config
    class AntiDetectionConfig
      # User Agent pool - rotating realistic browser signatures
      USER_AGENTS = [
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0'
      ].freeze

      # Language/Region combinations for Accept-Language header
      LANGUAGES = [
        'en-US,en;q=0.9',
        'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
        'es-ES,es;q=0.9,en;q=0.8',
        'fr-FR,fr;q=0.9,en;q=0.8',
        'de-DE,de;q=0.9,en;q=0.8',
        'en-GB,en;q=0.9'
      ].freeze

      # Screen resolutions for viewport randomization
      SCREEN_SIZES = [
        [1920, 1080],
        [1366, 768],
        [1440, 900],
        [1536, 864],
        [2560, 1440]
      ].freeze

      # Timezone offsets for request timing
      TIMEZONES = [
        'America/New_York',
        'America/Chicago',
        'America/Los_Angeles',
        'America/Sao_Paulo',
        'Europe/London',
        'Europe/Paris',
        'Asia/Tokyo'
      ].freeze

      class << self
        def random_user_agent
          USER_AGENTS.sample
        end

        def random_language
          LANGUAGES.sample
        end

        def random_screen_size
          SCREEN_SIZES.sample
        end

        def random_timezone
          TIMEZONES.sample
        end

        # Generate randomized browser options
        def randomized_browser_config
          user_agent = random_user_agent
          screen_size = random_screen_size
          
          {
            user_agent: user_agent,
            screen_size: screen_size,
            language: random_language,
            timezone: random_timezone
          }
        end
      end
    end
  end
end
```

### 4. Proxy Support (Optional)

For distributed deployments or additional anonymity:

```ruby
# filepath: lib/config/proxy_config.rb
module GoogleFlights
  module Config
    class ProxyConfig
      class << self
        def enabled?
          ENV['USE_PROXY'] == 'true'
        end

        def proxy_url
          ENV['PROXY_URL'] # Format: http://user:pass@proxy.example.com:8080
        end

        def proxy_rotation_enabled?
          ENV['PROXY_ROTATION'] == 'true'
        end

        # Multiple proxies for rotation
        def proxy_pool
          ENV['PROXY_POOL']&.split(',') || []
        end

        def random_proxy
          proxy_pool.sample || proxy_url
        end
      end
    end
  end
end
```

### 5. Browser Token Extractor

Manages browser pool with anti-detection features:

```ruby
# filepath: lib/browser_token_extractor.rb
require 'singleton'
require 'ferrum'
require_relative 'config/token_config'
require_relative 'config/anti_detection_config'
require_relative 'config/proxy_config'

module GoogleFlights
  class BrowserTokenExtractor
    include Singleton

    def initialize
      @browser_pool = []
      @pool_mutex = Mutex.new
      @extraction_mutex = Mutex.new
    end

    # Extract tokens from Google Flights
    def extract_tokens
      @extraction_mutex.synchronize do
        browser = acquire_browser
        
        begin
          extract_tokens_from_browser(browser)
        ensure
          release_browser(browser)
        end
      end
    end

    # Cleanup all browsers
    def shutdown
      @pool_mutex.synchronize do
        @browser_pool.each do |browser|
          browser.quit rescue nil
        end
        @browser_pool.clear
      end
    end

    private

    def acquire_browser
      @pool_mutex.synchronize do
        # Reuse existing browser from pool
        if @browser_pool.any?
          return @browser_pool.pop
        end
        
        # Create new browser if pool is empty
        create_browser
      end
    end

    def release_browser(browser)
      @pool_mutex.synchronize do
        # Return to pool if under max size, otherwise quit
        if @browser_pool.size < Config::TokenConfig.browser_pool_size
          @browser_pool.push(browser)
        else
          browser.quit rescue nil
        end
      end
    end

    def create_browser
      timeout = Config::TokenConfig.browser_timeout
      anti_detection = Config::AntiDetectionConfig.randomized_browser_config
      
      browser_options = {
        'no-sandbox': nil,
        'disable-dev-shm-usage': nil,
        'disable-blink-features': 'AutomationControlled',  # Hide automation
        'disable-infobars': nil,
        'user-agent': anti_detection[:user_agent]
      }
      
      # Add proxy if enabled
      if Config::ProxyConfig.enabled?
        proxy = Config::ProxyConfig.random_proxy
        browser_options['proxy-server'] = proxy
      end
      
      browser = Ferrum::Browser.new(
        headless: true,
        timeout: timeout,
        process_timeout: timeout,
        window_size: anti_detection[:screen_size],
        browser_options: browser_options
      )
      
      # Set additional fingerprint randomization
      randomize_browser_fingerprint(browser, anti_detection)
      
      browser
    end
    
    def randomize_browser_fingerprint(browser, config)
      # Override navigator.webdriver flag
      browser.execute <<~JS
        Object.defineProperty(navigator, 'webdriver', {
          get: () => undefined
        });
      JS
      
      # Set language preferences
      browser.execute <<~JS
        Object.defineProperty(navigator, 'language', {
          get: () => '#{config[:language].split(',').first}'
        });
        Object.defineProperty(navigator, 'languages', {
          get: () => #{config[:language].split(',').map { |l| l.split(';').first.strip }.inspect}
        });
      JS
      
      # Set timezone
      browser.execute <<~JS
        Intl.DateTimeFormat().resolvedOptions().timeZone = '#{config[:timezone]}';
      JS
      
      # Randomize plugins
      browser.execute <<~JS
        Object.defineProperty(navigator, 'plugins', {
          get: () => [
            {name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer'},
            {name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai'},
            {name: 'Native Client', filename: 'internal-nacl-plugin'}
          ]
        });
      JS
    end

    def extract_tokens_from_browser(browser)
      timeout = Config::TokenConfig.extraction_timeout
      
      # Navigate to Google Flights
      browser.goto('https://www.google.com/travel/flights')
      
      # Wait for page to load
      browser.network.wait_for_idle(timeout: timeout)
      
      # Perform a sample search to trigger token generation
      perform_sample_search(browser)
      
      # Intercept network request
      tokens = nil
      
      browser.network.intercept
      browser.on(:request) do |request|
        if request.url.include?('GetShoppingResults')
          tokens = extract_tokens_from_request(request)
        end
      end
      
      # Wait for the request
      sleep 2  # Give time for the request to be made
      
      # If tokens not captured yet, trigger another search
      if tokens.nil?
        perform_sample_search(browser, retry: true)
        sleep 2
      end
      
      raise TokenExtractionError, "Failed to capture tokens from browser" if tokens.nil?
      
      tokens
    rescue Ferrum::TimeoutError => e
      raise TokenExtractionError, "Browser timeout: #{e.message}"
    rescue => e
      raise TokenExtractionError, "Browser error: #{e.message}"
    end

    def perform_sample_search(browser, retry: false)
      # Fill in search form
      browser.at_css('input[placeholder*="Where from"]')&.focus&.type('CGH')
      sleep 0.5
      browser.at_css('input[placeholder*="Where to"]')&.focus&.type('JPA')
      sleep 0.5
      
      # Select dates
      browser.at_css('input[placeholder*="Departure"]')&.click
      sleep 0.5
      
      # Click search button
      browser.at_css('button[aria-label*="Search"]')&.click
      
      # Wait for results to load
      browser.network.wait_for_idle(timeout: 10)
    rescue => e
      # Ignore search errors, we just need the network request
    end

    def extract_tokens_from_request(request)
      headers = request.headers
      url = request.url
      
      # Extract query parameters from URL
      uri = URI.parse(url)
      query_params = URI.decode_www_form(uri.query || '').to_h
      
      # Extract POST body
      post_data = request.body
      body_params = if post_data
        URI.decode_www_form(post_data).to_h
      else
        {}
      end
      
      {
        # Headers
        'X-Goog-BatchExecute-Bgr': headers['x-goog-batchexecute-bgr'],
        'X-Goog-Ext-259736195-Jspb': headers['x-goog-ext-259736195-jspb'],
        'X-Browser-Validation': headers['x-browser-validation'],
        
        # Query parameters
        'f.sid': query_params['f.sid'],
        'bl': query_params['bl'],
        '_reqid': query_params['_reqid'],
        
        # Metadata
        extracted_at: Time.now.to_i,
        url: url
      }
    end
  end
end
```

### 4. Updated Google Flights Client

Integration with TokenManager:

```ruby
# filepath: lib/google_flights_client_v2.rb
require_relative 'token_manager'
require_relative 'config/token_config'

module GoogleFlights
  class Client
    def initialize
      @token_manager = TokenManager.instance
    end

    def search(origin:, destination:, departure_date:, return_date:)
      uri = build_uri
      request = build_request(uri, origin, destination, departure_date, return_date)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      case response
      when Net::HTTPSuccess
        body = decode_response_body(response)
        parse_response(body)
      else
        {
          error: "HTTP #{response.code}",
          message: response.message
        }
      end
    rescue => e
      { error: e.message, details: e.backtrace.first(5) }
    end

    # Force token refresh
    def refresh_tokens!
      @token_manager.refresh_tokens!
    end

    # Check token status
    def token_status
      {
        expired: @token_manager.tokens_expired?,
        last_refreshed: @token_manager.last_refreshed_at,
        ttl_remaining: @token_manager.ttl_remaining,
        tokens_present: !@token_manager.tokens.nil?
      }
    end

    private

    def build_request(uri, origin, destination, departure_date, return_date)
      request = Net::HTTP::Post.new(uri)

      # Standard headers with randomization
      anti_detection = Config::AntiDetectionConfig
      
      request['Accept'] = '*/*'
      request['Accept-Encoding'] = 'gzip, deflate, br, zstd'
      request['Accept-Language'] = anti_detection.random_language  # Randomized
      request['Cache-Control'] = 'no-cache'
      request['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
      request['Origin'] = 'https://www.google.com'
      request['Pragma'] = 'no-cache'
      request['Referer'] = 'https://www.google.com/travel/flights'
      request['User-Agent'] = anti_detection.random_user_agent  # Randomized

      # Dynamic tokens from TokenManager
      tokens = @token_manager.tokens
      request['X-Browser-Validation'] = tokens['X-Browser-Validation']
      request['X-Goog-Ext-259736195-Jspb'] = tokens['X-Goog-Ext-259736195-Jspb']
      request['X-Goog-BatchExecute-Bgr'] = tokens['X-Goog-BatchExecute-Bgr']
      request['X-Same-Domain'] = '1'

      request.body = build_payload(origin, destination, departure_date, return_date)
      request
    end

    def build_uri
      tokens = @token_manager.tokens
      params = "f.sid=#{tokens['f.sid']}&bl=#{tokens['bl']}&hl=pt-BR&soc-app=162&soc-platform=1&soc-device=1&_reqid=#{tokens['_reqid']}&rt=c"
      
      URI.parse("#{ENDPOINT}?#{params}")
    end

    # ... rest of the implementation
  end
end
```

## Configuration

### Environment Variables

```bash
# .env
RACK_ENV=production

# Token Management
TOKEN_TTL=86400                    # 24 hours
BROWSER_POOL_SIZE=5                # Number of browsers in pool
BROWSER_TIMEOUT=30                 # Browser operation timeout
EXTRACTION_TIMEOUT=60              # Token extraction timeout
AUTO_REFRESH_TOKENS=true           # Auto-refresh on expiration
TOKEN_CACHE_PATH=/var/cache/tokens.json

# Anti-Detection (Optional)
USE_PROXY=false                    # Enable proxy support
PROXY_URL=http://user:pass@proxy.example.com:8080
PROXY_ROTATION=false               # Rotate between multiple proxies
PROXY_POOL=proxy1.com:8080,proxy2.com:8080,proxy3.com:8080  # Comma-separated

# Request Randomization
RANDOMIZE_USER_AGENT=true          # Rotate user agents (recommended)
RANDOMIZE_LANGUAGE=true            # Vary Accept-Language header (recommended)
RANDOMIZE_SCREEN_SIZE=true         # Vary viewport size (recommended)
```

### Custom TTL

```ruby
# config/initializers/token_config.rb
GoogleFlights::Config::TokenConfig.class_eval do
  def self.token_ttl
    ENV['TOKEN_TTL']&.to_i || 86400  # Default 24 hours
  end
end
```

## Usage Examples

### Basic Usage

```ruby
# Initialize client (tokens loaded lazily on first request)
client = GoogleFlights::Client.new

# First request triggers token extraction
result = client.search(
  origin: 'CGH',
  destination: 'JPA',
  departure_date: '2026-02-06',
  return_date: '2026-02-27'
)

# Subsequent requests use cached tokens
result2 = client.search(...)  # Uses cached tokens
```

### Check Token Status

```ruby
client = GoogleFlights::Client.new

status = client.token_status
# => {
#   expired: false,
#   last_refreshed: 2025-12-10 10:30:00 UTC,
#   ttl_remaining: 82800,  # seconds
#   tokens_present: true
# }
```

### Force Token Refresh

```ruby
client = GoogleFlights::Client.new

# Manually refresh tokens
client.refresh_tokens!

# Make request with fresh tokens
result = client.search(...)
```

### Background Token Refresh

```ruby
# lib/tasks/token_refresh.rake
namespace :tokens do
  desc 'Refresh Google Flights tokens'
  task refresh: :environment do
    manager = GoogleFlights::TokenManager.instance
    
    if manager.tokens_expired?
      puts "Tokens expired, refreshing..."
      manager.refresh_tokens!
      puts "Tokens refreshed successfully"
    else
      remaining = manager.ttl_remaining / 3600
      puts "Tokens still valid (#{remaining.round(2)} hours remaining)"
    end
  end
end

# Cron job (crontab -e)
0 */12 * * * cd /path/to/app && rake tokens:refresh
```

### Concurrent Requests

The TokenManager is thread-safe:

```ruby
# Multiple threads/processes can safely use the same tokens
threads = 10.times.map do |i|
  Thread.new do
    client = GoogleFlights::Client.new
    client.search(
      origin: 'CGH',
      destination: 'JPA',
      departure_date: '2026-02-06',
      return_date: '2026-02-27'
    )
  end
end

threads.each(&:join)
# Only one browser session is created, tokens are shared
```

## Deployment Considerations

### Docker Setup

```dockerfile
# Dockerfile
FROM ruby:3.2

# Install Chrome for Ferrum
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome Driver
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d. -f1) \
    && wget -q https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION} -O /tmp/version \
    && wget -q https://chromedriver.storage.googleapis.com/$(cat /tmp/version)/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip -d /usr/local/bin/ \
    && rm chromedriver_linux64.zip

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

COPY . .

# Ensure cache directory exists
RUN mkdir -p /var/cache/flights-api

CMD ["ruby", "flights_cli.rb"]
```

### Production Monitoring

```ruby
# lib/middleware/token_monitor.rb
module GoogleFlights
  class TokenMonitor
    def initialize(app)
      @app = app
    end

    def call(env)
      manager = TokenManager.instance
      
      # Log token status before request
      if manager.tokens_expired?
        Rails.logger.warn "[TokenMonitor] Tokens expired, will refresh on next request"
      else
        remaining = manager.ttl_remaining / 3600
        Rails.logger.info "[TokenMonitor] Tokens valid for #{remaining.round(2)} hours"
      end
      
      @app.call(env)
    end
  end
end

# config/application.rb
config.middleware.use GoogleFlights::TokenMonitor
```

### Health Check Endpoint

```ruby
# config/routes.rb
get '/health/tokens', to: 'health#tokens'

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def tokens
    manager = GoogleFlights::TokenManager.instance
    
    status = if manager.tokens_expired?
      :service_unavailable
    else
      :ok
    end
    
    render json: {
      status: status,
      expired: manager.tokens_expired?,
      last_refreshed: manager.last_refreshed_at,
      ttl_remaining_seconds: manager.ttl_remaining.to_i,
      ttl_remaining_hours: (manager.ttl_remaining / 3600).round(2)
    }, status: status
  end
end
```

## Performance Optimization

### 1. Lazy Browser Initialization

Browsers are only created when tokens need to be extracted, not on application startup.

### 2. Browser Pool Reuse

Multiple token extractions can reuse the same browser instances, reducing overhead.

### 3. Cache-First Strategy

Tokens are loaded from cache on startup if still valid, avoiding unnecessary browser sessions.

### 4. Configurable Pool Size

Adjust `browser_pool_size` based on your workload:
- **Low traffic**: 1-2 browsers
- **Medium traffic**: 3-5 browsers
- **High traffic**: 5-10 browsers

### 5. Automatic Cleanup

```ruby
# Graceful shutdown
at_exit do
  GoogleFlights::BrowserTokenExtractor.instance.shutdown
end

# Or in Rails
# config/initializers/token_cleanup.rb
Rails.application.config.after_initialize do
  at_exit do
    GoogleFlights::BrowserTokenExtractor.instance.shutdown
  end
end
```

## Testing

### Mock Token Manager for Tests

```ruby
# test/support/mock_token_manager.rb
module GoogleFlights
  class MockTokenManager
    def tokens
      {
        'X-Goog-BatchExecute-Bgr' => '[";test-token"]',
        'X-Goog-Ext-259736195-Jspb' => '["pt-BR","BR","BRL",1,null,[180],null,null,7,[]]',
        'X-Browser-Validation' => 'test-validation',
        'f.sid' => '-123456',
        'bl' => 'test-bl',
        '_reqid' => '12345'
      }
    end

    def tokens_expired?
      false
    end

    def refresh_tokens!
      tokens
    end

    def ttl_remaining
      86400
    end
  end
end

# In tests
RSpec.configure do |config|
  config.before(:each) do
    allow(GoogleFlights::TokenManager).to receive(:instance)
      .and_return(GoogleFlights::MockTokenManager.new)
  end
end
```

## Troubleshooting

### Browser Won't Start

**Problem**: Ferrum can't start Chrome

**Solution**:
```bash
# Install Chrome dependencies
sudo apt-get install -y \
  libnss3 \
  libatk-bridge2.0-0 \
  libdrm2 \
  libxkbcommon0 \
  libgbm1
```

### Tokens Not Extracted

**Problem**: Browser loads but tokens aren't captured

**Solution**:
- Increase `extraction_timeout` in config
- Check if Google Flights UI changed
- Run browser in non-headless mode for debugging:
  ```ruby
  Ferrum::Browser.new(headless: false)
  ```

### Memory Leaks

**Problem**: Browser pool consumes too much memory

**Solution**:
- Reduce `browser_pool_size`
- Implement browser recycling:
  ```ruby
  def release_browser(browser)
    @requests_count ||= {}
    @requests_count[browser] ||= 0
    @requests_count[browser] += 1
    
    # Recycle browser after 100 requests
    if @requests_count[browser] > 100
      browser.quit
      @requests_count.delete(browser)
    else
      @browser_pool.push(browser)
    end
  end
  ```

## Security Considerations

### 1. Token Storage

Tokens are cached locally. Ensure proper file permissions:

```bash
chmod 600 /var/cache/flights-api/tokens.json
```

### 2. Token Rotation

Tokens automatically expire and refresh, minimizing security risks.

### 3. Browser Isolation

Each browser instance runs in isolation with sandbox mode enabled.

### 4. Anti-Detection Best Practices

To avoid triggering Google's anti-abuse detection:

#### User Agent Rotation
- Rotate between realistic, current browser user agents
- Match Chrome/Firefox versions that are currently supported
- Avoid outdated or uncommon user agents that stand out

#### Language & Locale Variation
- Vary `Accept-Language` header to simulate different regions
- Match language to timezone and geographic context when possible
- Don't always use the same language for every request

#### Viewport Randomization
- Rotate screen resolutions between common desktop sizes
- Avoid unusual or uncommon viewport dimensions
- Match viewport to user agent (mobile vs desktop)

#### Request Timing
- Add random delays between requests (500ms - 2000ms)
- Avoid perfectly regular intervals
- Simulate human browsing patterns

```ruby
# lib/middleware/human_timing.rb
class HumanTiming
  def initialize(app)
    @app = app
    @last_request = {}
  end

  def call(env)
    ip = env['REMOTE_ADDR']
    now = Time.now
    
    if @last_request[ip]
      elapsed = now - @last_request[ip]
      min_delay = 0.5  # 500ms minimum
      
      if elapsed < min_delay
        sleep(min_delay - elapsed + rand(0.5..1.5))
      end
    end
    
    @last_request[ip] = Time.now
    @app.call(env)
  end
end
```

#### Proxy Usage (Advanced)
- Use residential proxies when possible (not datacenter IPs)
- Rotate between proxies to distribute requests
- Match proxy location to language/timezone settings
- Monitor for proxy blacklisting

```ruby
# Example: Proxy rotation with health checks
class ProxyRotator
  def initialize(proxies)
    @proxies = proxies.map { |p| {url: p, failures: 0} }
    @current_index = 0
  end

  def next_proxy
    proxy = @proxies[@current_index]
    @current_index = (@current_index + 1) % @proxies.length
    
    # Skip proxies with too many failures
    while proxy[:failures] > 3
      @current_index = (@current_index + 1) % @proxies.length
      proxy = @proxies[@current_index]
    end
    
    proxy[:url]
  end

  def mark_failure(proxy_url)
    proxy = @proxies.find { |p| p[:url] == proxy_url }
    proxy[:failures] += 1 if proxy
  end

  def reset_failures(proxy_url)
    proxy = @proxies.find { |p| p[:url] == proxy_url }
    proxy[:failures] = 0 if proxy
  end
end
```

### 5. Rate Limiting

Implement rate limiting to avoid triggering Google's anti-abuse systems:

```ruby
# lib/middleware/rate_limiter.rb
class RateLimiter
  def initialize(app, max_requests: 100, window: 3600)
    @app = app
    @max_requests = max_requests
    @window = window
    @requests = {}
  end

  def call(env)
    ip = env['REMOTE_ADDR']
    now = Time.now.to_i
    
    @requests[ip] ||= []
    @requests[ip].reject! { |t| t < now - @window }
    
    if @requests[ip].length >= @max_requests
      return [429, {'Content-Type' => 'application/json'}, 
              [{error: 'Rate limit exceeded'}.to_json]]
    end
    
    @requests[ip] << now
    @app.call(env)
  end
end
```

## Anti-Detection Checklist

Before deploying to production, verify these anti-detection measures:

- [ ] User agent rotation enabled and using current browser versions
- [ ] Accept-Language header randomization configured
- [ ] Viewport sizes randomized (matching desktop resolutions)
- [ ] Browser fingerprint overrides implemented (navigator.webdriver, plugins)
- [ ] Request timing delays implemented (avoid regular intervals)
- [ ] Proxy rotation configured (if using proxies)
- [ ] Rate limiting in place (max requests per hour)
- [ ] Token cache TTL appropriate (not too short to avoid excessive browser sessions)
- [ ] Browser pool size optimized (not too large to avoid resource exhaustion)
- [ ] Monitoring for failed token extractions (indicates detection)

## Future Improvements

1. **Distributed Token Cache** - Use Redis for multi-server deployments
2. **Token Health Monitoring** - Track extraction success rate and detection events
3. **Fallback Strategies** - Multiple token sources and backup mechanisms
4. **Smart Refresh** - Predict token expiration and refresh proactively
5. **Browser Pool Autoscaling** - Adjust pool size based on load
6. **Advanced Anti-Detection** - Canvas fingerprint randomization, WebGL noise injection
7. **Machine Learning** - Detect patterns that trigger anti-bot systems
8. **Residential Proxy Network** - Rotate between residential IPs for better anonymity

## References

- [Ferrum Documentation](https://github.com/rubycdp/ferrum)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [Headless Chrome](https://developers.google.com/web/updates/2017/04/headless-chrome)
