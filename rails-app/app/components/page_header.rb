# frozen_string_literal: true

class Components::PageHeader < Components::Base
  attr_reader :title

  def initialize(title)
    @title = title
  end

  def view_template(&block)
    div(class: "md:flex md:items-center md:justify-between mb-6") do
      div(class: "min-w-0 flex-1") do
        h2(class: "text-2xl/7 font-bold text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight") do
          title
        end
      end

      div(class: "mt-4 flex md:ml-4 md:mt-0", &block) if block_given?
    end
  end

  def action(label, href: nil, primary: false, **attributes)
    classes = if primary
      "inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
    else
      "inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
    end

    classes += " ml-3" unless @first_action
    @first_action = false

    if href
      a(href: href, class: classes, **attributes) { label }
    else
      button(type: "button", class: classes, **attributes) { label }
    end
  end

  private

  def before_template
    @first_action = true
  end
end
