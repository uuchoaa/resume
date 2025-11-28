class Components::Select < Components::Base
  def initialize(name:, options:, selected: nil, label: nil, id: nil, disabled: false, error: false, **attributes)
    @name = name
    @options = options
    @selected = selected
    @label = label
    @id = id || name.to_s.tr("_", "-")
    @disabled = disabled
    @error = error
    @attributes = attributes
  end

  def view_template
    render_label if @label

    div(class: "mt-2 grid grid-cols-1") do
      select(
        name: @name,
        id: @id,
        disabled: @disabled,
        class: select_classes,
        **@attributes
      ) do
        @options.each do |option|
          render_option(option)
        end
      end

      # Chevron icon
      svg(
        viewBox: "0 0 16 16",
        fill: "currentColor",
        data_slot: "icon",
        aria_hidden: "true",
        class: "pointer-events-none col-start-1 row-start-1 mr-2 size-5 self-center justify-self-end text-gray-500 sm:size-4 dark:text-gray-400"
      ) do |s|
        s.path(
          d: "M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 0-1.06Z",
          clip_rule: "evenodd",
          fill_rule: "evenodd"
        )
      end
    end
  end

  private

  def render_label
    label(for: @id, class: "block text-sm/6 font-medium text-gray-900 dark:text-white") do
      plain @label
    end
  end

  def render_option(option)
    option(
      value: option[:value],
      selected: option[:value].to_s == @selected.to_s
    ) do
      plain option[:label]
    end
  end

  def select_classes
    base = "col-start-1 row-start-1 w-full appearance-none rounded-md bg-white py-1.5 pl-3 pr-8 text-base outline outline-1 -outline-offset-1 sm:text-sm/6 dark:*:bg-gray-800"

    if @error
      "#{base} text-red-900 outline-red-300 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-red-600 dark:bg-white/5 dark:text-red-400 dark:outline-red-500/50 dark:focus-visible:outline-red-400"
    elsif @disabled
      "#{base} text-gray-900 outline-gray-300 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-indigo-600 disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500 disabled:outline-gray-200 dark:bg-white/5 dark:text-gray-300 dark:outline-white/10 dark:focus-visible:outline-indigo-500 dark:disabled:bg-white/10 dark:disabled:text-gray-500 dark:disabled:outline-white/5"
    else
      "#{base} text-gray-900 outline-gray-300 focus-visible:outline focus-visible:outline-2 focus-visible:-outline-offset-2 focus-visible:outline-indigo-600 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:focus-visible:outline-indigo-500"
    end
  end
end
