class Components::Select < Components::Base
  def initialize(name:, options:, selected: nil, label: nil, id: nil, **attributes)
    @name = name
    @options = options
    @selected = selected
    @label = label
    @id = id || name.to_s.tr("_", "-")
    @attributes = attributes
  end

  def view_template
    render_label if @label

    div(class: "mt-2 grid grid-cols-1") do
      select(
        name: @name,
        id: @id,
        class: "col-start-1 row-start-1 w-full appearance-none rounded-md bg-white py-1.5 pl-3 pr-8 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:*:bg-gray-800 dark:focus:outline-indigo-500",
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
end
