# frozen_string_literal: true

class Views::Base < Cuy::Base
  # The `Views::Base` is an abstract class for all your views.

  attr_accessor :model
  attr_accessor :models
  attr_accessor :current_path

  def initialize(model = nil)
    @model = model
  end

  def render_page_header
    header do
      div(class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8") do
        page_header
      end
    end
  end

  def render_navbar
    render Cuy::Navbar.new(current_path) do |nav|
      nav.item("/deals/new") { "dekas" }
      nav.item("/agencies/new") { "agencies" }

      # nav.logo { Views::Logo }
    end
  end

  def view_template
    render_navbar

    div(class: 'py-10') do
      render_page_header
      render_main_content
    end
  end

  def render_main_content
    main do
      div(class: "mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8") do
        main_content
      end
    end
  end

  def main_content
    raise 'It should be overrided!'
  end

  def around_template(&)
    render Cuy::DefaultLayout.new(&)
  end
end
