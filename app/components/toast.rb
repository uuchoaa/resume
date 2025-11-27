# frozen_string_literal: true

class Components::Toast < Components::Base
  TYPES = {
    notice: {
      bg: "bg-white dark:bg-gray-800",
      text: "text-gray-900 dark:text-gray-100",
      icon_color: "text-green-500 dark:text-green-400",
      icon_path: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
    },
    alert: {
      bg: "bg-white dark:bg-gray-800",
      text: "text-gray-900 dark:text-gray-100",
      icon_color: "text-red-500 dark:text-red-400",
      icon_path: "M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z"
    },
    warning: {
      bg: "bg-white dark:bg-gray-800",
      text: "text-gray-900 dark:text-gray-100",
      icon_color: "text-yellow-500 dark:text-yellow-400",
      icon_path: "M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z"
    },
    info: {
      bg: "bg-white dark:bg-gray-800",
      text: "text-gray-900 dark:text-gray-100",
      icon_color: "text-blue-500 dark:text-blue-400",
      icon_path: "M10 18a8 8 0 100-16 8 8 0 000 16zm.75-13a.75.75 0 00-1.5 0v5a.75.75 0 001.5 0V5zM10 15a1 1 0 100-2 1 1 0 000 2z"
    }
  }.freeze

  def initialize(message:, type: :notice)
    @message = message
    @type = type.to_sym
    @config = TYPES[@type] || TYPES[:notice]
  end

  def view_template
    div(
      data: {
        controller: "toast",
        toast_type_value: @type
      },
      class: "pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg #{@config[:bg]} shadow-md ring-1 ring-gray-900/5 dark:ring-white/10 transform transition-all duration-500 ease-out translate-x-0 opacity-100"
    ) do
      div(class: "p-3") do
        div(class: "flex items-center gap-3") do
          # Icon (smaller)
          div(class: "flex-shrink-0") do
            svg(
              class: "h-5 w-5 #{@config[:icon_color]}",
              viewBox: "0 0 20 20",
              fill: "currentColor",
              aria_hidden: "true"
            ) do |s|
              s.path(
                fill_rule: "evenodd",
                d: @config[:icon_path],
                clip_rule: "evenodd"
              )
            end
          end

          # Message
          div(class: "flex-1") do
            p(class: "text-sm #{@config[:text]}") { @message }
          end

          # Close button
          div(class: "flex-shrink-0") do
            button(
              type: "button",
              data: { action: "toast#dismiss" },
              class: "inline-flex rounded-md text-gray-400 hover:text-gray-500 dark:hover:text-gray-300 focus:outline-none cursor-pointer"
            ) do
              span(class: "sr-only") { "Close" }
              svg(
                class: "h-4 w-4",
                viewBox: "0 0 20 20",
                fill: "currentColor",
                aria_hidden: "true"
              ) do |s|
                s.path(
                  d: "M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"
                )
              end
            end
          end
        end
      end
    end
  end
end
