require "test_helper"

class Components::KanbanTest < ActiveSupport::TestCase
  test "renders kanban board container" do
    grouped_data = {}
    columns = [ :open, :screening ]
    translator = ->(key) { key.to_s.humanize }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/flex gap-4 overflow-x-auto pb-4/, output)
  end

  test "renders columns" do
    grouped_data = { open: [], screening: [] }
    columns = [ :open, :screening ]
    translator = ->(key) { key.to_s.humanize }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/Open/, output)
    assert_match(/Screening/, output)
  end

  test "renders column with correct styling" do
    grouped_data = { open: [] }
    columns = [ :open ]
    translator = ->(key) { key.to_s.humanize }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/flex-shrink-0 w-80 bg-gray-100 rounded-lg p-4 min-h-\[600px\]/, output)
  end

  test "renders column header with translated name" do
    grouped_data = { open: [] }
    columns = [ :open ]
    translator = ->(key) { "Custom #{key}" }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/Custom open/, output)
    assert_match(/text-sm font-semibold text-gray-900/, output)
  end

  test "renders item count in column header" do
    grouped_data = { open: [ 1, 2, 3 ] }
    columns = [ :open ]
    translator = ->(key) { key.to_s }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/\(3\)/, output)
  end

  test "renders zero count for empty columns" do
    grouped_data = { open: [] }
    columns = [ :open ]
    translator = ->(key) { key.to_s }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/\(0\)/, output)
  end

  test "renders cards from block" do
    grouped_data = { open: [ "item1", "item2" ] }
    columns = [ :open ]
    translator = ->(key) { key.to_s }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call do |item|
      "<div>Card: #{item}</div>"
    end

    assert_match(/Card: item1/, output)
    assert_match(/Card: item2/, output)
  end

  test "handles missing columns in grouped_data" do
    grouped_data = { open: [ 1, 2 ] }
    columns = [ :open, :screening, :closed ]
    translator = ->(key) { key.to_s }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/open/, output)
    assert_match(/screening/, output)
    assert_match(/closed/, output)
    assert_match(/\(2\)/, output) # open has 2 items
    assert_match(/\(0\)/, output) # screening and closed have 0 items
  end

  test "renders multiple columns" do
    grouped_data = {
      open: [ 1 ],
      screening: [ 2, 3 ],
      offer: [ 4, 5, 6 ]
    }
    columns = [ :open, :screening, :offer ]
    translator = ->(key) { key.to_s.humanize }

    output = Components::Kanban.new(
      grouped_data: grouped_data,
      columns: columns,
      column_translator: translator
    ).call

    assert_match(/\(1\)/, output)
    assert_match(/\(2\)/, output)
    assert_match(/\(3\)/, output)
  end
end
