# frozen_string_literal: true

class Views::Base < Cuy::Base
  # The `Views::Base` is an abstract class for all your views.

  attr_accessor :model
  attr_accessor :current_path

  def initialize(model = nil)
    @model = model
  end

  def page_header
    h1(class: "font-bold text-4xl") { "#{@model&.class.to_s.humanize}" }
  end

  def navbar
    nav(class: "border-b border-gray-200 bg-white") do
      div(class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8") do
        yield
      end
    end
  end

  def view_template
    navbar do
      render Cuy::Navbar.new(current_path) do |nav|
        nav.item("/") { "Home" }
        nav.item("/agencies") { "agencies" }
      end
    end
    page_header
    div do
      main_content
    end
  end

  def main_content
    raise 'It should be overrided!'
  end

  def around_template(&)
    render Cuy::DefaultLayout.new(&)
  end
end
