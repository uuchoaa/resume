# frozen_string_literal: true

class Components::ModelForm < Components::Form
  attr_reader :model

  def initialize(model:, action: nil, method: nil, **attributes)
    @model = model
    @explicit_action = action

    # Determina method baseado no model se não fornecido
    if method.nil?
      method = model.persisted? ? :patch : :post
    end

    super(action: action, method: method, **attributes)
  end

  def view_template(&block)
    # Infere o action path durante o render, quando os helpers estão disponíveis
    @action = @explicit_action || infer_action_path

    # Cria uma section implícita para agrupar os campos
    form(action: @action, method: form_method, **@attributes) do
      render_method_field if spoofed_method?
      render_csrf_token

      # Container for sections
      div(class: "space-y-12") do
        yield self if block_given?
      end
    end
  end

  # Wrapper para agrupar attributes em uma section com grid
  def attributes(&block)
    div(class: "border-b border-gray-900/10 pb-12 dark:border-white/10") do
      div(class: "mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-12") do
        yield self if block_given?
      end
    end
  end

  # API simplificada: detecta automaticamente o tipo de campo
  # Renderiza o campo diretamente no grid (sem section wrapper)
  def attribute(name, **options)
    type = detect_field_type(name)
    label = options.delete(:label)
    label = @model.class.human_attribute_name(name) if label.nil?
    error = field_error(name)
    value = field_value(name, options.delete(:value))

    # Opções comuns
    common_options = {
      name: field_name(name),
      id: field_id(name),
      value: value,
      label: label,
      error: error,
      span: options.delete(:span),
      placeholder: options.delete(:placeholder),
      disabled: options.delete(:disabled),
      readonly: options.delete(:readonly),
      required: options.delete(:required),
      hint: options.delete(:hint),
      autofocus: options.delete(:autofocus),
      autocomplete: options.delete(:autocomplete)
    }

    # Delega para o componente Input apropriado
    case type
    when :email
      render Components::Inputs::Email.new(
        span: common_options[:span] || 6,
        **common_options.except(:span),
        **options
      )
    when :textarea
      render Components::Inputs::Textarea.new(
        span: common_options[:span] || 6,
        rows: options.delete(:rows),
        **common_options.except(:span),
        **options
      )
    when :select, :belongs_to, :enum
      render Components::Inputs::Select.new(
        span: common_options[:span] || 6,
        options: options.delete(:options) || select_options(name),
        selected: value,
        include_blank: options.delete(:include_blank) || false,
        prompt: options.delete(:prompt),
        **common_options.except(:span, :value),
        **options
      )
    else # :text ou desconhecido
      render Components::Inputs::Text.new(
        span: common_options[:span] || 6,
        **common_options.except(:span),
        **options
      )
    end
  end

  # Override field_name para incluir o namespace do model
  def field_name(name)
    # Para associações belongs_to, precisamos adicionar _id
    association = @model.class.reflect_on_association(name)
    field_key = association&.macro == :belongs_to ? "#{name}_id" : name
    "#{model_param_key}[#{field_key}]"
  end

  # Override field_id para incluir o namespace do model
  def field_id(name)
    # Para associações belongs_to, precisamos adicionar _id
    association = @model.class.reflect_on_association(name)
    field_key = association&.macro == :belongs_to ? "#{name}_id" : name
    "#{model_param_key}_#{field_key}"
  end

  # Override field_value para pegar do model se não fornecido explicitamente
  def field_value(name, explicit_value)
    return explicit_value unless explicit_value.nil?

    # Para associações belongs_to, pegar o ID
    association = @model.class.reflect_on_association(name)
    if association&.macro == :belongs_to
      return model.public_send("#{name}_id") if model.respond_to?("#{name}_id")
    end

    model.public_send(name) if model.respond_to?(name)
  end

  # Método para obter erros do model
  def field_error(name)
    return nil unless model.errors.any?

    # Para associações belongs_to, o erro pode estar em name_id
    association = @model.class.reflect_on_association(name)
    error_key = association&.macro == :belongs_to ? "#{name}_id" : name

    errors = model.errors[error_key]
    errors.first if errors.any?
  end

  private

  def model_param_key
    @model.model_name.param_key
  end

  def infer_action_path
    # Usa polimorphic_path que funciona com qualquer model
    # Para new record: /deals (POST)
    # Para persisted: /deals/1 (PATCH)
    if @model.persisted?
      helpers.url_for(@model)
    else
      helpers.url_for([ @model.class ])
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
