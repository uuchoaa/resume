# frozen_string_literal: true

class Components::ModelForm < Components::Form
  attr_reader :model

  def initialize(model:, action: nil, method: nil, **attributes)
    @model = model

    # Determina action baseado no model se não fornecido
    if action.nil?
      action = infer_action_path
    end

    # Determina method baseado no model se não fornecido
    if method.nil?
      method = model.persisted? ? :patch : :post
    end

    super(action: action, method: method, **attributes)
  end

  # API simplificada: detecta automaticamente o tipo de campo
  def attribute(name, **options)
    type = detect_field_type(name)
    label = options.delete(:label) || @model.class.human_attribute_name(name)
    error = field_error(name)

    case type
    when :text, :string
      section do |s|
        s.text(name, label: label, error: error, **options)
      end
    when :email
      section do |s|
        s.email(name, label: label, error: error, **options)
      end
    when :textarea
      section do |s|
        s.textarea(name, label: label, error: error, **options)
      end
    when :select, :belongs_to, :enum
      section do |s|
        s.select(name, label: label, options: select_options(name), error: error, **options)
      end
    end
  end

  # Override field_name para incluir o namespace do model
  def field_name(name)
    "#{model_param_key}[#{name}]"
  end

  # Override field_id para incluir o namespace do model
  def field_id(name)
    "#{model_param_key}_#{name}"
  end

  # Override field_value para pegar do model se não fornecido explicitamente
  def field_value(name, explicit_value)
    return explicit_value unless explicit_value.nil?

    model.public_send(name) if model.respond_to?(name)
  end

  # Método para obter erros do model
  def field_error(name)
    return nil unless model.errors.any?

    errors = model.errors[name]
    errors.first if errors.any?
  end

  private

  def model_param_key
    @model.model_name.param_key
  end

  def infer_action_path
    # Tenta usar os helpers de rotas do Rails
    # Para new record: plural_path (ex: deals_path)
    # Para persisted: singular_path (ex: deal_path(@deal))
    route_key = @model.model_name.route_key

    if @model.persisted?
      # Rota para update: /deals/1
      public_send("#{@model.model_name.singular_route_key}_path", @model)
    else
      # Rota para create: /deals
      public_send("#{route_key}_path")
    end
  rescue NoMethodError => e
    # Se não conseguir inferir, retorna nil e deixa o form sem action
    # (vai submeter para a URL atual)
    Rails.logger.debug("Could not infer action path for #{@model.class.name}: #{e.message}")
    nil
  end

  def detect_field_type(name)
    # Verifica se é uma associação belongs_to
    association = @model.class.reflect_on_association(name)
    return :select if association&.macro == :belongs_to

    # Verifica se é um enum
    return :select if @model.class.defined_enums.key?(name.to_s)

    # Verifica o tipo da coluna no schema
    column = @model.class.columns_hash[name.to_s]
    return :text unless column

    case column.type
    when :text
      :textarea
    when :string
      name.to_s.include?("email") ? :email : :text
    else
      :text
    end
  end

  def select_options(name)
    # Enum
    if @model.class.defined_enums.key?(name.to_s)
      return @model.class.public_send(name.to_s.pluralize).keys.map do |key|
        { value: key, label: @model.class.human_attribute_name("#{name}.#{key}") }
      end
    end

    # Associação belongs_to
    association = @model.class.reflect_on_association(name)
    if association&.macro == :belongs_to
      klass = association.klass
      return klass.all.map do |record|
        label = record.respond_to?(:name) ? record.name : record.to_s
        { value: record.id, label: label }
      end
    end

    []
  end
end
