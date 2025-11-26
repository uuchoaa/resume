module Views
  module ComponentPreviews
    class Show < Views::Base
      include ComponentPreviewsHelper

      def initialize(preview_class:, variant_name:)
        @preview_class = preview_class
        @variant_name = variant_name
        @component_name = preview_class.component_name
        @previews = preview_class.previews
        @selected_preview = @previews[@variant_name]
      end

      def view_template
        render Components::PageHeader.new(
          title: @component_name.titleize,
          subtitle: @selected_preview[:description],
          actions: [ { label: "← Back to all components", href: component_previews_path, primary: false } ]
        )

        div(class: "p-6") do
          # Variant tabs
          render_variant_tabs

          # Description section
          div(class: "mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4") do
            h4(class: "text-base font-semibold text-blue-900 mb-2") { @selected_preview[:name] }
            if @selected_preview[:description].present?
              p(class: "text-sm text-blue-800 leading-relaxed") { @selected_preview[:description] }
            end
          end

          # Preview section
          div(class: "mt-6 bg-white rounded-lg border border-gray-200 overflow-hidden") do
            div(class: "border-b border-gray-200 bg-gray-50 px-4 py-2") do
              h3(class: "text-sm font-semibold text-gray-700") { "Preview" }
            end
            div(class: "p-8 bg-gradient-to-br from-gray-50 to-gray-100") do
              div(class: "inline-block border-2 border-dashed border-blue-300 rounded-lg bg-white shadow-sm") do
                render @selected_preview[:block].call
              end
            end
          end

          # Code section
          div(class: "mt-6 bg-white rounded-lg border border-gray-200 overflow-hidden", data_controller: "clipboard") do
            div(class: "border-b border-gray-200 bg-gray-50 px-4 py-2 flex justify-between items-center") do
              h3(class: "text-sm font-semibold text-gray-700") { "Code" }
              button(
                data_clipboard_target: "button",
                data_action: "click->clipboard#copy",
                class: "px-3 py-1 text-sm bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
              ) do
                "Copy"
              end
            end
            div(class: "p-4 bg-gray-900 overflow-x-auto") do
              pre(class: "text-sm", data_clipboard_target: "source") do
                code do
                  raw highlight_ruby(extract_source(@selected_preview))
                end
              end
            end
          end
        end
      end

      private

      def render_variant_tabs
        div(class: "border-b border-gray-200") do
          nav(class: "flex space-x-4") do
            @previews.each do |variant, _|
              is_active = variant == @variant_name

              a(
                href: component_preview_path(@component_name, variant: variant),
                class: [
                  "px-4 py-2 text-sm font-medium border-b-2 transition-colors",
                  is_active ? "border-blue-500 text-blue-600" : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                ].join(" ")
              ) do
                variant.to_s.humanize
              end
            end
          end
        end
      end
    end
  end
end
