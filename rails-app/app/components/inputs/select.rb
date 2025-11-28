# frozen_string_literal: true

module Components::Inputs
  class Select < Base
    attr_reader :options, :include_blank, :prompt

    def initialize(options:, selected: nil, include_blank: false, prompt: nil, **args)
      @options = options
      @include_blank = include_blank
      @prompt = prompt
      super(value: selected, **args)
    end

    def view_template
      render Components::Form::Field.new(
        label: @label,
        span: @span,
        error: @error,
        field_id: @id,
        required: @required,
        hint: @hint
      ) do
        render Components::Select.new(
          name: @name,
          id: @id,
          options: formatted_options,
          selected: @value,
          error: @error.present?,
          disabled: @disabled,
          **@attributes
        )
      end
    end

    private

    def formatted_options
      opts = []

      # Adiciona opção em branco se solicitado
      if @include_blank
        opts << { value: "", label: @prompt || "Selecione..." }
      end

      # Adiciona as opções reais
      opts + @options
    end
  end
end
