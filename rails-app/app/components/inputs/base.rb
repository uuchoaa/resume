# frozen_string_literal: true

module Components::Inputs
  class Base < Components::Base
    attr_reader :name, :id, :value, :label, :error, :span, :placeholder,
                :disabled, :readonly, :required, :hint, :autofocus, :autocomplete

    def initialize(
      name:,
      id: nil,
      value: nil,
      label: nil,
      error: nil,
      span: 3,
      placeholder: nil,
      disabled: false,
      readonly: false,
      required: false,
      hint: nil,
      autofocus: false,
      autocomplete: nil,
      **attributes
    )
      @name = name
      @id = id || name.to_s.gsub(/[\[\]]/, "_").gsub(/__+/, "_").gsub(/^_|_$/, "")
      @value = value
      @label = label
      @error = error
      @span = span
      @placeholder = placeholder
      @disabled = disabled
      @readonly = readonly
      @required = required
      @hint = hint
      @autofocus = autofocus
      @autocomplete = autocomplete
      @attributes = attributes
    end

    def view_template
      raise NotImplementedError, "Subclasses must implement view_template"
    end

    private

    def input_classes(error: false, disabled: false)
      base = "block w-full rounded-md bg-white px-3 py-1.5 text-base outline outline-1 -outline-offset-1 sm:text-sm/6"

      if error
        "#{base} text-red-900 outline-red-300 placeholder:text-red-300 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-red-600 dark:bg-white/5 dark:text-red-400 dark:outline-red-500/50 dark:placeholder:text-red-400/70 dark:focus:outline-red-400"
      elsif disabled
        "#{base} text-gray-900 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500 disabled:outline-gray-200 dark:bg-white/5 dark:text-gray-300 dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500 dark:disabled:bg-white/10 dark:disabled:text-gray-500 dark:disabled:outline-white/5"
      else
        "#{base} text-gray-900 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
      end
    end

    def input_aria_attributes
      return {} unless @error

      {
        "aria-invalid": "true",
        "aria-describedby": "#{@id}-error"
      }
    end

    def common_input_attrs
      {
        placeholder: @placeholder,
        disabled: @disabled,
        readonly: @readonly,
        required: @required,
        autofocus: @autofocus,
        autocomplete: @autocomplete
      }.compact
    end
  end
end
