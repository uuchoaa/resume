# frozen_string_literal: true

class Components::Modal < Components::Base
  attr_reader :id, :title

  def initialize(id:, title:)
    @id = id
    @title = title
  end

  def view_template(&block)
    # Modal backdrop
    div(id: id, class: "hidden fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity z-50") do
      # Modal container
      div(class: "fixed inset-0 z-50 overflow-y-auto") do
        div(class: "flex min-h-full items-center justify-center p-4 text-center sm:p-0") do
          # Modal content
          div(class: "relative transform overflow-hidden rounded-lg bg-white dark:bg-gray-800 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg") do
            # Header
            div(class: "bg-white dark:bg-gray-800 px-4 pt-5 pb-4 sm:p-6 sm:pb-4") do
              div(class: "flex items-start justify-between") do
                h3(class: "text-lg font-semibold text-gray-900 dark:text-white") { title }
                button(
                  type: "button",
                  class: "text-gray-400 hover:text-gray-500 dark:hover:text-gray-300",
                  data_modal_close: id
                ) do
                  span(class: "sr-only") { "Close" }
                  plain "×"
                end
              end
              
              # Body
              div(class: "mt-4", &block)
            end
          end
        end
      end
    end
  end
end
