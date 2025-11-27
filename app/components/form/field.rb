# frozen_string_literal: true

class Components::Form::Field < Components::Base
  def initialize(label: nil, span: 4, description: nil, **attributes)
    @label = label
    @span = span
    @description = description
    @attributes = attributes
  end

  def view_template(&block)
    div(class: span_class, **@attributes) do
      # Label
      if @label
        label(class: "block text-sm/6 font-medium text-gray-900 dark:text-white") do
          plain @label
        end
      end

      # Input wrapper
      div(class: "mt-2") do
        yield if block_given?
      end

      # Description/help text
      if @description
        p(class: "mt-3 text-sm/6 text-gray-600 dark:text-gray-400") do
          plain @description
        end
      end
    end
  end

  private

  def span_class
    case @span
    when :full, 6
      "col-span-full"
    when 2
      "sm:col-span-2"
    when 3
      "sm:col-span-3"
    when 4
      "sm:col-span-4"
    else
      "sm:col-span-#{@span}"
    end
  end
end
