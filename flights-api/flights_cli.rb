#!/usr/bin/env ruby

require_relative 'google_flights_client'
require 'optparse'
require 'json'

class FlightsCLI
  def initialize
    @options = {
      output: 'table'
    }
    @parser = setup_parser
  end

  def run(args)
    @parser.parse!(args)
    
    if @options[:help]
      puts @parser.help
      return
    end

    validate_required_options!
    search_flights
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
    puts "Error: #{e.message}"
    puts @parser.help
    exit 1
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end

  private

  def setup_parser
    OptionParser.new do |opts|
      opts.banner = "Usage: flights_cli.rb [options]"
      opts.separator ""
      opts.separator "Search for flights on Google Flights"
      opts.separator ""
      opts.separator "Required options:"

      opts.on("-o", "--origin AIRPORT", "Origin airport code (e.g., CGH, GRU)") do |v|
        @options[:origin] = v
      end

      opts.on("-d", "--destination AIRPORT", "Destination airport code (e.g., JPA)") do |v|
        @options[:destination] = v
      end

      opts.on("--departure DATE", "Departure date (YYYY-MM-DD)") do |v|
        @options[:departure_date] = v
      end

      opts.on("--return DATE", "Return date (YYYY-MM-DD)") do |v|
        @options[:return_date] = v
      end

      opts.separator ""
      opts.separator "Optional options:"

      opts.on("--format FORMAT", [:table, :json, :compact], 
              "Output format: table, json, compact (default: table)") do |v|
        @options[:output] = v
      end

      opts.on("--max LIMIT", Integer, "Maximum number of flights to show") do |v|
        @options[:max] = v
      end

      opts.on("-h", "--help", "Show this help message") do
        @options[:help] = true
      end
    end
  end

  def validate_required_options!
    required = [:origin, :destination, :departure_date, :return_date]
    missing = required.select { |opt| @options[opt].nil? }
    
    if missing.any?
      raise "Missing required options: #{missing.map { |o| "--#{o.to_s.gsub('_', '-')}" }.join(', ')}"
    end

    validate_date_format!(@options[:departure_date], 'departure')
    validate_date_format!(@options[:return_date], 'return')
  end

  def validate_date_format!(date, label)
    unless date =~ /^\d{4}-\d{2}-\d{2}$/
      raise "Invalid #{label} date format. Use YYYY-MM-DD"
    end
  end

  def search_flights
    puts "🔍 Searching flights from #{@options[:origin]} to #{@options[:destination]}..."
    puts "   Departure: #{@options[:departure_date]}"
    puts "   Return: #{@options[:return_date]}"
    puts ""

    client = GoogleFlightsClient.new
    result = client.search(
      origin: @options[:origin],
      destination: @options[:destination],
      departure_date: @options[:departure_date],
      return_date: @options[:return_date]
    )

    if result[:error]
      puts "❌ Error: #{result[:error]}"
      puts "   #{result[:message]}" if result[:message]
      exit 1
    end

    display_results(result)
  end

  def display_results(result)
    flights = result[:best_flights]
    flights = flights.take(@options[:max]) if @options[:max]

    if flights.empty?
      puts "No flights found."
      return
    end

    case @options[:output]
    when :json
      puts JSON.pretty_generate(result)
    when :compact
      display_compact(flights)
    else
      display_table(flights)
    end
  end

  def display_table(flights)
    puts "✈️  Found #{flights.length} flight#{flights.length == 1 ? '' : 's'}:"
    puts ""
    puts "─" * 100
    
    flights.each_with_index do |flight, i|
      puts "Flight #{i + 1}:"
      puts "  Airline:     #{flight[:airline]} (#{flight[:airline_code]}) - #{flight[:flight_number]}"
      puts "  Route:       #{flight[:departure_airport][:code]} → #{flight[:arrival_airport][:code]}"
      puts "  Departure:   #{format_time(flight[:departure_time])}"
      puts "  Arrival:     #{format_time(flight[:arrival_time])}"
      puts "  Duration:    #{format_duration(flight[:duration])}"
      puts "  Stops:       #{flight[:stops] == 0 ? 'Direct' : "#{flight[:stops]} stop#{flight[:stops] == 1 ? '' : 's'}"}"
      puts "  Airplane:    #{flight[:airplane]}"
      puts "  Price:       R$ #{format_price(flight[:price])}"
      
      if flight[:extensions] && !flight[:extensions].empty?
        puts "  Amenities:   #{flight[:extensions].join(', ')}"
      end
      
      puts "─" * 100
    end

    if flights.any? { |f| f[:price] }
      cheapest = flights.min_by { |f| f[:price] }
      puts ""
      puts "💰 Cheapest flight: #{cheapest[:airline]} #{cheapest[:flight_number]} - R$ #{format_price(cheapest[:price])}"
    end
  end

  def display_compact(flights)
    puts "✈️  Found #{flights.length} flight#{flights.length == 1 ? '' : 's'}:"
    puts ""
    
    flights.each_with_index do |flight, i|
      stops_text = flight[:stops] == 0 ? 'Direct' : "#{flight[:stops]} stop#{flight[:stops] == 1 ? '' : 's'}"
      puts "#{i + 1}. #{flight[:airline]} #{flight[:flight_number]} | #{format_time(flight[:departure_time])} → #{format_time(flight[:arrival_time])} | #{format_duration(flight[:duration])} | #{stops_text} | R$ #{format_price(flight[:price])}"
    end
  end

  def format_time(time_str)
    return 'N/A' unless time_str
    # Convert ISO 8601 to readable format: "2026-02-06T19:40:00-03:00" -> "19:40"
    time_str.match(/T(\d{2}:\d{2})/)[1]
  rescue
    time_str
  end

  def format_duration(minutes)
    return 'N/A' unless minutes
    hours = minutes / 60
    mins = minutes % 60
    "#{hours}h #{mins}m"
  end

  def format_price(price)
    return 'N/A' unless price
    "%.2f" % price
  end
end

if __FILE__ == $0
  cli = FlightsCLI.new
  cli.run(ARGV)
end
