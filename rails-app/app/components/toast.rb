# frozen_string_literal: true

class Components::Toast < Components::Base
  TYPES = {
    notice: {
      icon_color: "text-green-400",
      icon_path: "M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    },
    alert: {
      icon_color: "text-red-400",
      icon_path: "m9.75 9.75 4.5 4.5m0-4.5-4.5 4.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    },
    warning: {
      icon_color: "text-yellow-400",
      icon_path: "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
    },
    info: {
      icon_color: "text-blue-400",
      icon_path: "m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z"
    }
  }.freeze

  def initialize(message:, type: :notice, description: nil)
    @message = message
    @description = description
    @type = type.to_sym
    @config = TYPES[@type] || TYPES[:notice]
  end

  def view_template
    div(
      data: {
        controller: "toast",
        toast_type_value: @type
      },
      class: "pointer-events-auto w-full max-w-sm translate-y-0 transform rounded-lg bg-white opacity-100 shadow-lg outline outline-1 outline-black/5 transition duration-300 ease-out sm:translate-x-0"
    ) do
      div(class: "p-4") do
        div(class: "flex items-start") do
          # Icon
          div(class: "shrink-0") do
            svg(
              viewBox: "0 0 24 24",
              fill: "none",
              stroke: "currentColor",
              stroke_width: "1.5",
              aria_hidden: "true",
              class: "size-6 #{@config[:icon_color]}"
            ) do |s|
              s.path(
                d: @config[:icon_path],
                stroke_linecap: "round",
                stroke_linejoin: "round"
              )
            end
          end

          # Message
          div(class: "ml-3 w-0 flex-1 pt-0.5") do
            p(class: "text-sm font-medium text-gray-900") { @message }
            if @description
              p(class: "mt-1 text-sm text-gray-500") { @description }
            end
          end

          # Close button
          div(class: "ml-4 flex shrink-0") do
            button(
              type: "button",
              data: { action: "toast#dismiss" },
              class: "inline-flex rounded-md text-gray-400 hover:text-gray-500 focus:outline focus:outline-2 focus:outline-offset-2 focus:outline-indigo-600"
            ) do
              span(class: "sr-only") { "Close" }
              svg(
                viewBox: "0 0 20 20",
                fill: "currentColor",
                aria_hidden: "true",
                class: "size-5"
              ) do |s|
                s.path(
                  d: "M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z"
                )
              end
            end
          end
        end
      end
    end
  end
end
