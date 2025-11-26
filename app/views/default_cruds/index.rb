module Views
  module DefaultCruds
    class Index < Views::Base
      def page_title
        data.model_name.human(count: 2) if data.respond_to?(:model_name)
      end

      def view_template(&)
        render Table.new(data) { |table| setup_columns(table) }
      end

      private

      def setup_columns(table)
        model_class = data.model

        model_class.attribute_names.each do |attr|
          add_column(table, attr, model_class)
        end
      end

      def add_column(table, attr, model_class)
        column_name = model_class.human_attribute_name(attr)

        table.column(column_name) do |item|
          if attr == "id"
            id_link(item)
          else
            format_value(item.public_send(attr))
          end
        end
      end

      def format_value(value)
        case value
        when Time, DateTime, ActiveSupport::TimeWithZone
          I18n.l(value, format: :short)
        when Date
          I18n.l(value, format: :short)
        else
          value
        end
      end

      def id_link(item)
        a(href: "/#{data.model_name.route_key}/#{item.id}") { item.id }
      end
    end
  end
end
