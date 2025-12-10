#!/usr/bin/env ruby
# frozen_string_literal: true

# Test suite runner for Google Flights Client
# Runs all test files in the test directory

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Load all test files
test_files = Dir[File.join(__dir__, 'test', '*_test.rb')]

if test_files.empty?
  puts "No test files found in test/ directory"
  exit 1
end

puts "Running Google Flights Client Test Suite"
puts "=" * 60
puts "Loading test files:"
test_files.each do |file|
  puts "  - #{File.basename(file)}"
  require file
end
puts "=" * 60
puts ""
