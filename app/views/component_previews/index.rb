module Views
  module ComponentPreviews
    class Index < Views::Base
      def initialize(preview_classes:)
        @preview_classes = preview_classes
      end

      def view_template
        render Components::PageHeader.new(
          title: "Component Previews",
          subtitle: "Browse and test all available Phlex components"
        )

        div(class: "p-6") do
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
            @preview_classes.each do |preview_class|
              render_preview_card(preview_class)
            end
          end
        end
      end

      private

      def render_preview_card(preview_class)
        component_name = preview_class.component_name
        previews = preview_class.previews

        a(
          href: component_preview_path(component_name),
          class: "block bg-white rounded-lg border border-gray-200 hover:border-blue-500 hover:shadow-lg transition-all p-6"
        ) do
          h3(class: "text-lg font-semibold text-gray-900 mb-2") { component_name.titleize }
          p(class: "text-sm text-gray-600") do
            "#{previews.size} #{'variant'.pluralize(previews.size)}"
          end

          div(class: "mt-4 flex flex-wrap gap-2") do
            previews.keys.first(3).each do |variant|
              span(class: "inline-block px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded") do
                variant.to_s.humanize
              end
            end

            if previews.size > 3
              span(class: "inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded") do
                "+#{previews.size - 3} more"
              end
            end
          end
        end
      end
    end
  end
end
