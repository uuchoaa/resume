# Rails Integration & Model-Aware Components

> Leverage Rails' introspection capabilities to supercharge Cuy components with intelligent, convention-driven behavior.

## 🧠 Overview

Cuy components can tap into Rails' rich metadata about your models to automatically generate forms, tables, and detail views with zero configuration. This leverages:

- **Column types** - Auto-select appropriate input types
- **Associations** - Render belongs_to as selects, has_many as lists
- **Enums** - Generate select options with I18n labels
- **Validations** - Show required fields, apply constraints
- **I18n** - Use model translations for labels automatically
- **Model names** - Human-friendly naming throughout

## 🎯 Philosophy

**Convention over Configuration**: If you follow Rails conventions, Cuy components work automatically. Override only when you need custom behavior.

## 📦 Model-Aware Components

### 1. ModelForm - Auto-Generated Forms

Automatically generates complete forms from ActiveRecord models.

#### Basic Usage (Fully Automatic)

```ruby
# app/views/posts/edit.rb
class Views::Posts::Edit < Views::Base
  def view_template
    render Cuy::ModelForm.new(model: @post)
  end
end
```

That's it! The form will:
- ✅ Detect all editable attributes (excludes id, timestamps)
- ✅ Choose correct input types (text, email, date, select, etc.)
- ✅ Render enums as select dropdowns
- ✅ Render associations as selects
- ✅ Mark required fields from validations
- ✅ Use I18n for labels
- ✅ Set correct form action and method

#### Explicit Attribute Declaration

For more control, explicitly declare which attributes to include:

```ruby
# app/views/posts/edit.rb
class Views::Posts::Edit < Views::Base
  def view_template
    render Cuy::ModelForm.new(model: @post) do |form|
      # Declare attributes explicitly - auto-detects types
      form.attribute :title
      form.attribute :body
      form.attribute :status        # Auto-renders enum as select
      form.attribute :author_id     # Auto-renders association as select
      form.attribute :published_at  # Auto-renders as date picker
      
      # Override auto-detection with options
      form.attribute :body, as: :rich_text
      form.attribute :priority, as: :radio
      
      # Add custom fields
      form.field(label: "Tags") do
        render Cuy::TagInput.new(name: "post[tags]")
      end
    end
  end
end
```

#### Advanced Attribute Options

```ruby
render Cuy::ModelForm.new(model: @post) do |form|
  # Basic attribute
  form.attribute :title
  
  # Override type
  form.attribute :body, as: :textarea, rows: 10
  
  # Custom label and hint
  form.attribute :title, 
    label: "Post Title",
    hint: "Make it catchy!"
  
  # Override options for selects
  form.attribute :status,
    options: Post.statuses.keys.map { |k| [k.titleize, k] }
  
  # Add HTML attributes
  form.attribute :title,
    class: "custom-input",
    placeholder: "Enter title..."
  
  # Conditional rendering
  form.attribute :scheduled_at if @post.can_be_scheduled?
end
```

#### Manual Field Customization

```ruby
# Mix auto-generated with custom fields
render Cuy::ModelForm.new(model: @post) do |form|
  # Auto-generated attributes
  form.attribute :title
  form.attribute :status
  
  # Fully custom field
  form.field(label: "Custom Body Editor") do
    render Cuy::RichTextEditor.new(
      name: "post[body]",
      value: @post.body,
      toolbar: :full
    )
  end
  
  # Another custom field
  form.field(label: "Tags") do
    render Cuy::TagInput.new(name: "post[tags]")
  end
end
```

#### Implementation

```ruby
# cuy/lib/cuy/components/model_form.rb
module Cuy
  module Components
    class ModelForm < Cuy::Component
      def initialize(model:, action: nil, method: :post, auto_fields: true)
        @model = model
        @model_class = model.class
        @action = action || default_action
        @method = method
        @auto_fields = auto_fields  # Auto-generate all fields if no block
        @explicit_attributes = []
      end

      def view_template(&block)
        render Cuy::Form.new(action: @action, method: @method) do |form|
          # If block provided, yield for explicit attribute declarations
          if block_given?
            yield FormBuilder.new(self, form)
          else
            # Auto-generate all fields
            render_fields(form)
          end
          
          # Submit button
          form.actions do
            render Cuy::Button.new(type: :submit, variant: :primary) do
              @model.new_record? ? "Create #{model_name}" : "Update #{model_name}"
            end
          end
        end
      end
      
      # FormBuilder provides the DSL interface
      class FormBuilder
        def initialize(model_form, form)
          @model_form = model_form
          @form = form
        end
        
        # form.attribute :title
        # form.attribute :body, as: :textarea, rows: 10
        def attribute(attr, as: nil, **options)
          @model_form.render_attribute(@form, attr, as, **options)
        end
        
        # form.field(label: "Custom") { ... }
        def field(label:, **options, &block)
          @form.field(label: label, **options, &block)
        end
        
        # Delegate other methods to form
        def method_missing(method, *args, &block)
          @form.send(method, *args, &block)
        end
      end
      
      # Public API for FormBuilder to call
      def render_attribute(form, attr, type_override = nil, **options)
        column = @model_class.columns_hash[attr.to_s]
        
        form.field(
          label: options[:label] || human_attribute_name(attr),
          hint: options[:hint] || hint_for(attr),
          required: options[:required] || required?(attr)
        ) do
          render_input_for(attr, column, type_override, **options)
        end
      end

      private

      def render_fields(form)
        editable_attributes.each do |attr|
          render_field_for(form, attr)
        end
      end

      def render_field_for(form, attr)
        column = @model_class.columns_hash[attr.to_s]
        
        form.field(
          label: human_attribute_name(attr),
          hint: hint_for(attr),
          required: required?(attr)
        ) do
          render_input_for(attr, column)
        end
      end

      def render_input_for(attr, column, type_override = nil, **options)
        # Use explicit type if provided, otherwise auto-detect
        input_type = type_override || detect_input_type(attr, column)
        
        case input_type
        when :select, :enum
          render_enum_select(attr, options)
        when :association, :belongs_to
          render_association_select(attr, options)
        when :textarea, :text
          render Cuy::Textarea.new(
            name: field_name(attr),
            value: @model.send(attr),
            rows: options[:rows] || 5,
            **options.except(:rows, :label, :hint, :required)
          )
        when :rich_text
          render Cuy::RichTextEditor.new(
            name: field_name(attr),
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :checkbox, :boolean
          render Cuy::Checkbox.new(
            name: field_name(attr),
            checked: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :radio
          render_radio_group(attr, options)
        when :date
          render Cuy::Input.new(
            name: field_name(attr),
            type: :date,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :datetime
          render Cuy::Input.new(
            name: field_name(attr),
            type: :datetime_local,
            value: @model.send(attr)&.strftime('%Y-%m-%dT%H:%M'),
            **options.except(:label, :hint, :required)
          )
        when :email
          render Cuy::Input.new(
            name: field_name(attr),
            type: :email,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :tel, :phone
          render Cuy::Input.new(
            name: field_name(attr),
            type: :tel,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :number
          render Cuy::Input.new(
            name: field_name(attr),
            type: :number,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :url
          render Cuy::Input.new(
            name: field_name(attr),
            type: :url,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        when :password
          render Cuy::Input.new(
            name: field_name(attr),
            type: :password,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        else
          render Cuy::Input.new(
            name: field_name(attr),
            type: :text,
            value: @model.send(attr),
            **options.except(:label, :hint, :required)
          )
        end
      end
      
      def detect_input_type(attr, column)
        # Priority order: enum > association > column type > name pattern
        return :enum if enum_attribute?(attr)
        return :association if association_attribute?(attr)
        
        case column&.type
        when :text
          :textarea
        when :boolean
          :checkbox
        when :date
          :date
        when :datetime
          :datetime
        when :integer, :decimal, :float
          :number
        else
          # Detect from attribute name
          attr_str = attr.to_s
          case
          when attr_str.include?('email')
            :email
          when attr_str.include?('phone') || attr_str.include?('tel')
            :tel
          when attr_str.include?('url') || attr_str.include?('website')
            :url
          when attr_str.include?('password')
            :password
          else
            :text
          end
        end
      end

      def render_enum_select(attr, custom_options = {})
        options = if custom_options[:options]
          custom_options[:options]
        else
          @model_class.send(attr.to_s.pluralize).keys.map do |key|
            [human_enum_value(attr, key), key]
          end
        end
        
        render Cuy::Select.new(
          name: field_name(attr),
          options: options,
          selected: @model.send(attr),
          **custom_options.except(:options, :label, :hint, :required)
        )
      end

      def render_association_select(attr, custom_options = {})
        association = @model_class.reflect_on_association(attr)
        related_class = association.klass
        
        options = if custom_options[:options]
          custom_options[:options]
        else
          related_class.all.map { |r| [r.to_s, r.id] }
        end
        
        render Cuy::Select.new(
          name: "#{model_param_name}[#{attr}_id]",
          options: options,
          selected: @model.send("#{attr}_id"),
          **custom_options.except(:options, :label, :hint, :required)
        )
      end
      
      def render_radio_group(attr, custom_options = {})
        options = if custom_options[:options]
          custom_options[:options]
        elsif enum_attribute?(attr)
          @model_class.send(attr.to_s.pluralize).keys.map do |key|
            [human_enum_value(attr, key), key]
          end
        else
          []
        end
        
        render Cuy::RadioGroup.new(
          name: field_name(attr),
          options: options,
          selected: @model.send(attr),
          **custom_options.except(:options, :label, :hint, :required)
        )
      end

      # Rails introspection helpers
      def editable_attributes
        @model_class.column_names.reject do |attr|
          %w[id created_at updated_at].include?(attr)
        end
      end

      def enum_attribute?(attr)
        @model_class.defined_enums.key?(attr.to_s)
      end

      def association_attribute?(attr)
        @model_class.reflect_on_all_associations(:belongs_to)
          .any? { |a| a.name.to_s == attr.to_s }
      end

      def required?(attr)
        validators = @model_class.validators_on(attr)
        validators.any? { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
      end

      def human_attribute_name(attr)
        @model_class.human_attribute_name(attr)
      end

      def human_enum_value(attr, key)
        @model_class.human_attribute_name("#{attr}.#{key}")
      end

      def hint_for(attr)
        I18n.t("activerecord.hints.#{model_param_name}.#{attr}", default: nil)
      end

      def model_name
        @model_class.model_name.human
      end

      def model_param_name
        @model_class.model_name.param_key
      end

      def field_name(attr)
        "#{model_param_name}[#{attr}]"
      end

      def default_action
        @model.new_record? ? 
          "/#{model_param_name.pluralize}" : 
          "/#{model_param_name.pluralize}/#{@model.id}"
      end
    end
  end
end
```

### 2. ModelTable - Auto-Generated Tables

Smart tables that understand your models.

#### Basic Usage

```ruby
# app/views/posts/index.rb
class Views::Posts::Index < Views::Base
  def view_template
    render Cuy::ModelTable.new(collection: @posts)
  end
end
```

Automatically:
- ✅ Detects main columns (skips IDs, timestamps)
- ✅ Formats dates and booleans
- ✅ Renders enums as badges
- ✅ Adds View/Edit action links
- ✅ Uses I18n for column headers

#### Advanced Usage

```ruby
# Specify columns and customize
render Cuy::ModelTable.new(
  collection: @posts,
  columns: [:title, :author, :status, :published_at],
  actions: true
) do |table|
  # Add custom columns
  table.column("Custom") do |post|
    render Cuy::Badge.new { post.custom_status }
  end
end
```

#### Implementation

```ruby
# cuy/lib/cuy/components/model_table.rb
module Cuy
  module Components
    class ModelTable < Cuy::Component
      def initialize(collection:, columns: nil, actions: true)
        @collection = collection
        @model_class = collection.first&.class || collection.model
        @columns = columns || auto_detect_columns
        @actions = actions
      end

      def view_template
        render Cuy::Table.new do |table|
          table.header do
            @columns.each do |col|
              th { human_attribute_name(col) }
            end
            th { "Actions" } if @actions
          end

          table.body do
            @collection.each do |record|
              tr do
                @columns.each do |col|
                  td { format_value(record, col) }
                end
                td { render_actions(record) } if @actions
              end
            end
          end
        end
      end

      private

      def auto_detect_columns
        @model_class.column_names.reject do |col|
          col.in?(%w[id created_at updated_at]) || col.end_with?('_id')
        end.take(5)
      end

      def format_value(record, column)
        value = record.send(column)
        column_type = @model_class.columns_hash[column.to_s]&.type
        
        case column_type
        when :datetime, :date
          value&.strftime('%b %d, %Y')
        when :boolean
          render Cuy::Badge.new(variant: value ? :success : :neutral) do
            value ? "Yes" : "No"
          end
        else
          if @model_class.defined_enums.key?(column.to_s)
            render Cuy::Badge.new do
              human_enum_value(column, value)
            end
          else
            value
          end
        end
      end

      def render_actions(record)
        div(class: "flex gap-2") do
          a(href: show_path(record), class: "text-blue-600 hover:underline") { "View" }
          a(href: edit_path(record), class: "text-indigo-600 hover:underline") { "Edit" }
        end
      end

      def human_attribute_name(attr)
        @model_class.human_attribute_name(attr)
      end

      def human_enum_value(attr, key)
        @model_class.human_attribute_name("#{attr}.#{key}")
      end

      def show_path(record)
        "/#{model_param_name.pluralize}/#{record.id}"
      end

      def edit_path(record)
        "/#{model_param_name.pluralize}/#{record.id}/edit"
      end

      def model_param_name
        @model_class.model_name.param_key
      end
    end
  end
end
```

### 3. ModelDetails - Auto-Generated Detail Views

Show all model attributes in a beautiful description list.

#### Basic Usage

```ruby
# app/views/posts/show.rb
class Views::Posts::Show < Views::Base
  def view_template
    render Cuy::ModelDetails.new(model: @post)
  end
end
```

Automatically:
- ✅ Shows all attributes (except IDs, timestamps)
- ✅ Formats dates, booleans, enums
- ✅ Shows associations with links
- ✅ Counts has_many relationships
- ✅ Uses I18n for labels
- ✅ Smart spanning for text fields

#### Advanced Usage

```ruby
# Specify which attributes and associations
render Cuy::ModelDetails.new(
  model: @post,
  attributes: [:title, :body, :status, :published_at],
  associations: true  # Show belongs_to and has_many
)
```

#### Implementation

```ruby
# cuy/lib/cuy/components/model_details.rb
module Cuy
  module Components
    class ModelDetails < Cuy::Component
      def initialize(model:, attributes: nil, associations: true)
        @model = model
        @model_class = model.class
        @attributes = attributes || auto_detect_attributes
        @associations = associations
      end

      def view_template
        render Cuy::DescriptionList.new do |dl|
          @attributes.each do |attr|
            render_attribute(dl, attr)
          end
          
          render_associations(dl) if @associations
        end
      end

      private

      def render_attribute(dl, attr)
        column = @model_class.columns_hash[attr.to_s]
        value = @model.send(attr)
        
        dl.item(
          label: human_attribute_name(attr),
          value: format_attribute_value(attr, value, column),
          span: text_attribute?(column) ? 2 : 1
        )
      end

      def render_associations(dl)
        # belongs_to
        @model_class.reflect_on_all_associations(:belongs_to).each do |assoc|
          next if assoc.name.to_s.in?(%w[user account])
          
          related = @model.send(assoc.name)
          next unless related
          
          dl.item(
            label: assoc.klass.model_name.human,
            value: link_to_if(true, related.to_s, show_path(related))
          )
        end
        
        # has_many (show count)
        @model_class.reflect_on_all_associations(:has_many).each do |assoc|
          count = @model.send(assoc.name).count
          
          dl.item(
            label: assoc.klass.model_name.human(count: count),
            value: "#{count} #{assoc.klass.model_name.human(count: count).downcase}"
          )
        end
      end

      def format_attribute_value(attr, value, column)
        return "—" if value.nil?
        
        case column&.type
        when :datetime
          value.strftime('%B %d, %Y at %I:%M %p')
        when :date
          value.strftime('%B %d, %Y')
        when :boolean
          render Cuy::Badge.new(variant: value ? :success : :neutral) do
            value ? "Yes" : "No"
          end
        else
          if @model_class.defined_enums.key?(attr.to_s)
            render Cuy::Badge.new do
              human_enum_value(attr, value)
            end
          else
            value
          end
        end
      end

      def auto_detect_attributes
        @model_class.column_names.reject do |col|
          col.in?(%w[id created_at updated_at]) || col.end_with?('_id')
        end
      end

      def text_attribute?(column)
        column&.type == :text
      end

      def human_attribute_name(attr)
        @model_class.human_attribute_name(attr)
      end

      def human_enum_value(attr, key)
        @model_class.human_attribute_name("#{attr}.#{key}")
      end

      def show_path(record)
        "/#{record.class.model_name.route_key}/#{record.id}"
      end
    end
  end
end
```

### 4. AssociationList - Smart Association Rendering

Automatically render related records.

#### Usage

```ruby
# Show all comments for a post
render Cuy::AssociationList.new(
  parent: @post,
  association: :comments
)
```

This will:
- ✅ Use `ModelTable` to display the collection
- ✅ Show empty state if no records
- ✅ Include "Add New" button with correct params

#### Implementation

```ruby
# cuy/lib/cuy/components/association_list.rb
module Cuy
  module Components
    class AssociationList < Cuy::Component
      def initialize(parent:, association:)
        @parent = parent
        @association_name = association
        @association = parent.class.reflect_on_association(association)
        @collection = parent.send(association)
      end

      def view_template
        render Cuy::Card.new(
          title: @association.klass.model_name.human(count: @collection.count),
          subtitle: "#{@collection.count} records"
        ) do
          if @collection.any?
            render Cuy::ModelTable.new(collection: @collection)
          else
            render Cuy::EmptyState.new(
              title: "No #{@association.klass.model_name.human(count: 0).downcase}",
              description: "Add your first record",
              action_label: "Add #{@association.klass.model_name.human}",
              action_href: new_path
            )
          end
        end
      end

      private

      def new_path
        "/#{@association.klass.model_name.route_key}/new?#{@parent.class.model_name.param_key}_id=#{@parent.id}"
      end
    end
  end
end
```

### 5. ModelFilters - Auto-Generated Filter Forms

Smart filter forms that adapt to your model.

#### Usage

```ruby
# app/views/posts/index.rb
class Views::Posts::Index < Views::Base
  def view_template
    render Cuy::ModelFilters.new(
      model_class: Post,
      params: params
    )
    
    render Cuy::ModelTable.new(collection: @posts)
  end
end
```

Automatically generates:
- ✅ Search field for text attributes
- ✅ Select filters for enums
- ✅ Select filters for belongs_to associations
- ✅ Date range filters
- ✅ All with proper I18n labels

## 🎨 Complete Example: CRUD Views

Here's how simple a complete CRUD interface becomes:

### Index View

```ruby
# app/views/deals/index.rb
class Views::Deals::Index < Views::Base
  def view_template
    page = Cuy::Components::Page.new
    
    page
      .header do
        h1 { Deal.model_name.human(count: 2) }
        render Cuy::Button.new(
          variant: :primary,
          href: new_deal_path
        ) { "New Deal" }
      end
      .main do
        render Cuy::ModelFilters.new(
          model_class: Deal,
          params: params
        )
        
        render Cuy::ModelTable.new(collection: @deals)
      end
    
    render page
  end
end
```

### Show View

```ruby
# app/views/deals/show.rb
class Views::Deals::Show < Views::Base
  def view_template
    page = Cuy::Components::Page.new
    
    page
      .header do
        h1 { @deal.title }
        render Cuy::Badge.new { @deal.stage }
      end
      .main do
        render Cuy::ModelDetails.new(model: @deal)
        
        render Cuy::AssociationList.new(
          parent: @deal,
          association: :activities
        )
      end
      .aside do
        render Cuy::Timeline.new(events: @deal.events)
      end
    
    render page
  end
end
```

### Edit View

```ruby
# app/views/deals/edit.rb
class Views::Deals::Edit < Views::Base
  def view_template
    page = Cuy::Components::Page.new
    
    page
      .header { h1 { "Edit #{@deal.title}" } }
      .main do
        render Cuy::ModelForm.new(model: @deal)
      end
    
    render page
  end
end
```

That's it! **3 simple views for complete CRUD functionality.**

## 🔧 Configuration

### Custom Attribute Detection

Override which attributes are editable:

```ruby
# config/initializers/cuy.rb
Cuy.configure do |config|
  config.model_form.excluded_attributes = %w[
    id created_at updated_at deleted_at
    encrypted_password reset_password_token
  ]
  
  config.model_form.hidden_suffixes = %w[_id _digest _token]
end
```

### Custom Type Detection

Add custom type detection logic:

```ruby
Cuy.configure do |config|
  config.model_form.type_detectors << lambda do |attr, column|
    if attr.to_s.end_with?('_url')
      :url
    elsif attr.to_s.include?('price') || attr.to_s.include?('amount')
      :currency
    end
  end
end
```

### Custom Formatters

Add custom value formatters:

```ruby
Cuy.configure do |config|
  config.model_details.formatters[:currency] = lambda do |value|
    number_to_currency(value)
  end
  
  config.model_details.formatters[:percentage] = lambda do |value|
    number_to_percentage(value * 100, precision: 1)
  end
end
```

## 🎯 Rails Introspection APIs Used

Cuy leverages these Rails APIs:

### Model Metadata
```ruby
Model.columns_hash              # Column types and metadata
Model.column_names              # All column names
Model.model_name                # Model naming info
Model.model_name.human          # I18n name
Model.model_name.param_key      # URL parameter name
```

### Associations
```ruby
Model.reflect_on_all_associations(:belongs_to)
Model.reflect_on_all_associations(:has_many)
Model.reflect_on_association(:association_name)
```

### Enums
```ruby
Model.defined_enums             # All enum definitions
Model.stage.values              # Enum keys
Model.human_attribute_name("stage.open")  # I18n enum value
```

### Validations
```ruby
Model.validators_on(:attribute)
validator.is_a?(ActiveModel::Validations::PresenceValidator)
```

### I18n
```ruby
Model.human_attribute_name(:attribute)
I18n.t("activerecord.attributes.model.attribute")
I18n.t("activerecord.hints.model.attribute")
```

## 🚀 Benefits

### Before Cuy (Manual)

```ruby
# 50+ lines per form
def view_template
  form(action: deals_path, method: :post) do
    div(class: "space-y-4") do
      div do
        label { "Title" }
        input(name: "deal[title]", type: :text, value: @deal.title)
      end
      
      div do
        label { "Stage" }
        select(name: "deal[stage]") do
          Deal.stages.keys.each do |stage|
            option(value: stage, selected: @deal.stage == stage) do
              Deal.human_attribute_name("stage.#{stage}")
            end
          end
        end
      end
      
      div do
        label { "Agency" }
        select(name: "deal[agency_id]") do
          Agency.all.each do |agency|
            option(value: agency.id, selected: @deal.agency_id == agency.id) do
              agency.name
            end
          end
        end
      end
      
      # ... 10 more fields ...
      
      button(type: :submit) { "Save" }
    end
  end
end
```

### After Cuy (Automatic)

```ruby
# 1 line
def view_template
  render Cuy::ModelForm.new(model: @deal)
end
```

### Savings

- **95% less code** to maintain
- **Zero repetition** across forms
- **Automatic updates** when model changes
- **Consistent UX** across all forms
- **Built-in I18n** support
- **Type-safe inputs** by default

## 🎓 Learning More

- See [README.md](./README.md) for general Cuy documentation
- See component implementations in `lib/cuy/components/`
- Run Phlexbook to see live examples

---

**Rails + Cuy = Rapid Development** 🚀

