# frozen_string_literal: true

class Components::Form::ActionButtons < Components::Base
  def initialize(form:)
    @form = form
  end

  def view_template(&block)
    div(class: "mt-6 flex items-center justify-end gap-x-6") do
      if block_given?
        yield self
      else
        # Botões padrão
        cancel
        submit
      end
    end
  end

  # Cancel/reset button
  def cancel(label = nil, href: nil, **attributes)
    label ||= I18n.t("helpers.submit.cancel", default: "Cancelar")

    if href
      a(
        href: href,
        class: "text-sm/6 font-semibold text-gray-900 dark:text-white",
        **attributes
      ) { label }
    else
      button(
        type: "button",
        data: { controller: "history", action: "click->history#back" },
        class: "text-sm/6 font-semibold text-gray-900 dark:text-white cursor-pointer",
        **attributes
      ) { label }
    end
  end

  # Submit button
  def submit(label = nil, **attributes)
    label ||= I18n.t("helpers.submit.submit", default: "Salvar")

    button(
      type: "submit",
      class: "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:focus-visible:outline-indigo-500 cursor-pointer",
      **attributes
    ) { label }
  end
end
