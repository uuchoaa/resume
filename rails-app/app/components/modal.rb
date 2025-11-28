# frozen_string_literal: true

class Components::Modal < Components::Base
  attr_reader :id, :title

  def initialize(id:, title:)
    @id = id
    @title = title
  end

  def view_template(&block)
    # Hidden container
    div(
      id: id,
      class: "hidden fixed inset-0 z-50",
      aria_labelledby: "#{id}-title",
      role: "dialog",
      aria_modal: "true"
    ) do
      # Backdrop
      div(
        data_modal_backdrop: id,
        class: "fixed inset-0 bg-gray-500/75 transition-opacity duration-300 ease-out opacity-0"
      )

      # Modal container
      div(class: "fixed inset-0 z-50 overflow-y-auto") do
        div(class: "flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0") do
          # Modal panel
          div(
            data_modal_panel: id,
            class: "relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all duration-300 ease-out translate-y-4 opacity-0 sm:my-8 sm:w-full sm:max-w-lg sm:p-6 sm:translate-y-0 sm:scale-95"
          ) do
            # Header with close button
            div(class: "flex items-start justify-between mb-4") do
              h3(id: "#{id}-title", class: "text-base font-semibold text-gray-900") { title }
              button(
                type: "button",
                class: "rounded-md text-gray-400 hover:text-gray-500 focus:outline-none",
                data_modal_close: id
              ) do
                span(class: "sr-only") { "Close" }
                svg(
                  class: "size-6",
                  fill: "none",
                  viewbox: "0 0 24 24",
                  stroke_width: "1.5",
                  stroke: "currentColor",
                  aria_hidden: "true",
                  xmlns: "http://www.w3.org/2000/svg"
                ) do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M6 18L18 6M6 6l12 12")
                end
              end
            end

            # Body
            div(&block)
          end
        end
      end
    end
  end
end
