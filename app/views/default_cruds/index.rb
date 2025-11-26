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

        # Adiciona colunas de atributos
        model_class.attribute_names.each do |attr|
          add_column(table, attr, model_class)
        end

        # Adiciona colunas de associações (has_many, has_one, etc)
        model_class.reflect_on_all_associations.each do |association|
          # Pula belongs_to pois já é exibido como atributo (foreign_key)
          next if association.macro == :belongs_to

          add_association_column(table, association)
        end
      end

      def add_association_column(table, association)
        column_name = association.klass.model_name.human(count: 2)

        table.column(column_name) do |item|
          related_objects = item.public_send(association.name)

          case association.macro
          when :has_many, :has_and_belongs_to_many
            "#{related_objects.count} #{association.klass.model_name.human(count: related_objects.count)}"
          when :has_one
            related_objects&.try(:name) || related_objects&.try(:title) || related_objects&.to_s
          end
        end
      end

      def add_column(table, attr, model_class)
        # Pula colunas de foreign keys, pois serão tratadas como associações
        if attr.end_with?("_id")
          association_name = attr.delete_suffix("_id")
          association = model_class.reflect_on_association(association_name.to_sym)
          if association && association.macro == :belongs_to
            add_belongs_to_column(table, association)
            return
          end
        end

        column_name = model_class.human_attribute_name(attr)

        table.column(column_name) do |item|
          if attr == "id"
            id_link(item)
          else
            format_value(item.public_send(attr))
          end
        end
      end

      def add_belongs_to_column(table, association)
        column_name = association.klass.model_name.human

        table.column(column_name) do |item|
          related_object = item.public_send(association.name)
          next if related_object.nil?

          related_object.try(:name) ||
          related_object.try(:title) ||
          related_object.try(:email) ||
          "#{association.klass.model_name.human} ##{related_object.id}"
        end
      end

      def format_association(value, association)
        return nil if value.nil?

        case association.macro
        when :belongs_to, :has_one
          # Busca o objeto relacionado e tenta exibir um atributo legível
          related_object = association.klass.find_by(id: value)
          return nil unless related_object

          related_object.try(:name) ||
          related_object.try(:title) ||
          related_object.try(:email) ||
          "#{association.klass.model_name.human} ##{related_object.id}"
        when :has_many, :has_and_belongs_to_many
          "#{value.count} #{association.klass.model_name.human(count: value.count)}"
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
