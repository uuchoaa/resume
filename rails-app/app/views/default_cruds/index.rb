module Views
  module DefaultCruds
    class Index < Views::Base
      def page_title
        data.model_name.human(count: 2) if data.respond_to?(:model_name)
      end

      def view_template(&)
        render_page_header

        render Table.new(data) { |table| setup_columns(table) }
      end

      def render_page_header
        render Components::PageHeader.new(page_title) do |header|
          header.action("Novo", href: "/#{data.model_name.route_key}/new", primary: true)
        end
      end

      private

      def setup_columns(table)
        model_class = data.model

        # Separa timestamps dos outros atributos
        timestamps = %w[created_at updated_at]
        regular_attrs = model_class.attribute_names.reject { |attr| timestamps.include?(attr) }

        # Adiciona colunas de atributos regulares primeiro
        regular_attrs.each do |attr|
          add_column(table, attr, model_class)
        end

        # Adiciona colunas de associações (has_many, has_one, etc)
        model_class.reflect_on_all_associations.each do |association|
          # Pula belongs_to pois já é exibido como atributo (foreign_key)
          next if association.macro == :belongs_to

          add_association_column(table, association)
        end

        # Adiciona timestamps por último
        timestamps.each do |attr|
          add_column(table, attr, model_class) if model_class.attribute_names.include?(attr)
        end
      end

      def add_association_column(table, association)
        column_name = association.klass.model_name.human(count: 2)

        table.column(column_name) do |item|
          value = item.public_send(association.name)
          component = attribute_component_for_association(value, association, item)
          render component
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
          value = item.public_send(attr)
          component = attribute_component_for(attr, value, model_class)
          render component
        end
      end

      def add_belongs_to_column(table, association)
        column_name = association.klass.model_name.human

        table.column(column_name) do |item|
          related_object = item.public_send(association.name)
          component = Components::Attributes::BelongsToAttribute.new(
            value: related_object&.id,
            attribute_name: association.name.to_s,
            model_class: data.model,
            association: association
          )
          render component
        end
      end

      def attribute_component_for(attr, value, model_class)
        case attr
        when "id"
          Components::Attributes::IdAttribute.new(value: value, attribute_name: attr, model_class: model_class)
        when "created_at", "updated_at"
          Components::Attributes::TimestampAttribute.new(value: value, attribute_name: attr, model_class: model_class)
        else
          # Verifica se é enum
          if model_class.defined_enums.key?(attr)
            Components::Attributes::EnumAttribute.new(value: value, attribute_name: attr, model_class: model_class)
          else
            Components::Attributes::Base.new(value: value, attribute_name: attr, model_class: model_class)
          end
        end
      end

      def attribute_component_for_association(value, association, item)
        case association.macro
        when :has_many, :has_and_belongs_to_many
          Components::Attributes::HasManyAttribute.new(
            value: value,
            attribute_name: association.name.to_s,
            model_class: association.active_record,
            association: association,
            item_id: item.id
          )
        when :has_one
          Components::Attributes::BelongsToAttribute.new(
            value: value&.id,
            attribute_name: association.name.to_s,
            model_class: association.active_record,
            association: association
          )
        end
      end
    end
  end
end
