# frozen_string_literal: true

class Components::Form::ActionButtons < Components::Base
  def initialize(form:)
    @form = form
  end

  def view_template(&block)
    div(class: "mt-6 flex items-center justify-end gap-x-6") do
      yield self if block_given?
    end
  end

  # Cancel/reset button
  def cancel(label = "Cancel", **attributes)
    button(
      type: "button",
      class: "text-sm/6 font-semibold text-gray-900 dark:text-white",
      **attributes
    ) { label }
  end

  # Submit button
  def submit(label = "Save", **attributes)
    button(
      type: "submit",
      class: "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:focus-visible:outline-indigo-500",
      **attributes
    ) { label }
  end
end
