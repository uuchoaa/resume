require "test_helper"

class Components::NavTest < ActiveSupport::TestCase
  test "renders navigation container" do
    output = Components::Nav.new("/agencies").call

    assert_match(/hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8/, output)
    assert_match(/<div/, output)
  end

  test "renders active navigation item" do
    output = Components::Nav.new("/agencies").call do |nav|
      nav.item("/agencies") { "Agencies" }
    end

    assert_match(/Agencies/, output)
    assert_match(/border-indigo-600/, output)
    assert_match(/text-gray-900/, output)
    assert_match(/href="\/agencies"/, output)
  end

  test "renders inactive navigation item" do
    output = Components::Nav.new("/deals").call do |nav|
      nav.item("/agencies") { "Agencies" }
    end

    assert_match(/Agencies/, output)
    assert_match(/border-transparent/, output)
    assert_match(/text-gray-500/, output)
    refute_match(/border-indigo-600/, output)
  end

  test "activates item when path starts with href" do
    output = Components::Nav.new("/agencies/123").call do |nav|
      nav.item("/agencies") { "Agencies" }
    end

    assert_match(/border-indigo-600/, output)
    assert_match(/text-gray-900/, output)
  end

  test "renders multiple navigation items" do
    output = Components::Nav.new("/agencies").call do |nav|
      nav.item("/agencies") { "Agencies" }
      nav.item("/deals") { "Deals" }
      nav.item("/recruters") { "Recruiters" }
    end

    assert_match(/Agencies/, output)
    assert_match(/Deals/, output)
    assert_match(/Recruiters/, output)
  end

  test "applies hover styles to inactive items" do
    output = Components::Nav.new("/deals").call do |nav|
      nav.item("/agencies") { "Agencies" }
    end

    assert_match(/hover:border-gray-300/, output)
    assert_match(/hover:text-gray-700/, output)
  end
end
