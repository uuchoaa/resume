require "test_helper"

class Components::TableTest < ActiveSupport::TestCase
  test "renders empty table" do
    output = Components::Table.new([]).call

    assert_match(/<table/, output)
    assert_match(/min-w-full divide-y divide-gray-300/, output)
    assert_match(/<thead/, output)
    assert_match(/<tbody/, output)
  end

  test "renders table with columns" do
    rows = [ { name: "John", age: 30 } ]

    output = Components::Table.new(rows).call do |table|
      table.column("Name") { |row| row[:name] }
      table.column("Age") { |row| row[:age] }
    end

    assert_match(/Name/, output)
    assert_match(/Age/, output)
    assert_match(/<th/, output)
  end

  test "renders table with rows" do
    rows = [
      { name: "John", age: 30 },
      { name: "Jane", age: 25 }
    ]

    output = Components::Table.new(rows).call do |table|
      table.column("Name") { |row| row[:name] }
      table.column("Age") { |row| row[:age] }
    end

    assert_match(/John/, output)
    assert_match(/30/, output)
    assert_match(/Jane/, output)
    assert_match(/25/, output)
    assert_match(/<td/, output)
  end

  test "renders with correct CSS classes" do
    rows = [ { name: "Test" } ]

    output = Components::Table.new(rows).call do |table|
      table.column("Name") { |row| row[:name] }
    end

    assert_match(/px-3 py-3.5 text-left text-sm font-semibold text-gray-900/, output)
    assert_match(/whitespace-nowrap px-3 py-4 text-sm text-gray-500/, output)
    assert_match(/divide-y divide-gray-200/, output)
  end

  test "handles complex column content" do
    rows = [ { user: { name: "John", email: "john@example.com" } } ]

    output = Components::Table.new(rows).call do |table|
      table.column("User") do |row|
        "#{row[:user][:name]} (#{row[:user][:email]})"
      end
    end

    assert_match(/John \(john@example.com\)/, output)
  end

  test "renders multiple columns correctly" do
    rows = [ { a: 1, b: 2, c: 3 } ]

    output = Components::Table.new(rows).call do |table|
      table.column("A") { |row| row[:a] }
      table.column("B") { |row| row[:b] }
      table.column("C") { |row| row[:c] }
    end

    # Verify all columns are present
    assert_match(/A/, output)
    assert_match(/B/, output)
    assert_match(/C/, output)
    assert_match(/1/, output)
    assert_match(/2/, output)
    assert_match(/3/, output)
  end
end
