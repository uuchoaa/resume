# frozen_string_literal: true

class Views::Base < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags

  attr_accessor :current_path
  attr_accessor :page_title
  attr_accessor :data

  def around_template
    doctype

    html(class: "bg-white h-full") do
      head do
        title { page_title || "Resume" }

        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "application-name", content: "Resume")
        meta(name: "mobile-web-app-capable", content: "yes")

        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")

        csrf_meta_tags
        stylesheet_link_tag :app, "data-turbo-track": "reload"
        javascript_importmap_tags
      end

      body(class: "bg-white h-full") do
        div(class: "min-h-full") do
          render_navbar

          div(class: "py-10") do
            main(class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8") do
              yield
            end
          end
        end

        # Toast notifications container (top-right)
        render_toasts
      end
    end
  end

  def page_header
    page_title
  end

  private

  def render_navbar
    nav(class: "border-b border-gray-200 bg-white") do
      div(class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8") do
        div(class: "flex h-16 items-center justify-between") do
          div(class: "flex") do
            div(class: "flex shrink-0 items-center") do
              render_logo
            end

            render_desktop_menu
          end

          div(class: "hidden sm:ml-6 sm:flex sm:items-center") do
            # placeholder
          end

          div(class: "-mr-2 flex items-center sm:hidden") do
            # placeholder
          end
        end
      end

      render_mobile_menu
    end
  end

  def render_mobile_menu
  end

  def render_desktop_menu
    render Nav.new(current_path) do |nav|
      resource_routes.each do |route|
        nav.item(route[:path]) { route[:name] }
      end

      # Kitchen Sink link
      nav.item(kitchen_sink_root_path) { "Kitchen Sink" }
    end
  end

  def resource_routes
    routes = []

    Rails.application.routes.routes.each do |route|
      # Pega apenas rotas GET com action index
      next unless route.verb.match?(/GET/)
      next unless route.defaults[:action] == "index"
      next if route.defaults[:controller].blank?

      controller = route.defaults[:controller]
      path = "/#{controller}"

      # Usa I18n para traduzir o nome do resource
      begin
        model_name = controller.singularize.camelize.constantize.model_name
        name = model_name.human(count: 2)
        routes << { path: path, name: name }
      rescue NameError
        # Ignora se o model não existir
      end
    end

    routes.uniq { |r| r[:path] }
  end

  def render_logo
    div(class: "h-10 w-10") do
      svg(viewBox: "0 0 1024 1024", xmlns: "http://www.w3.org/2000/svg", class: "h-full w-full") do |s|
        s.defs do
          s.linearGradient(
            id: "indigoGradient",
            x1: "0%",
            y1: "0%",
            x2: "100%",
            y2: "100%"
          ) do
            s.stop(offset: "0%", style: "stop-color:#818cf8;stop-opacity:1")
            s.stop(offset: "100%", style: "stop-color:#4f46e5;stop-opacity:1")
          end
        end
        s.path(d: "M153.9 105.9h715.4v812.8H153.9z", fill: "url(#indigoGradient)")
        s.path(
          d:
            "M877.3 926.8H145.9V97.9h731.4v828.9z m-715.4-16h699.4V113.9H161.9v796.9z",
          fill: "#1e1b4b"
        )
        s.path(d: "M221.3 182.9h580.5v658.8H221.3z", fill: "#FFFFFF")
        s.path(
          d:
            "M793.8 833.8h16v16h-16zM777.7 849.8h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0H568v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0H439v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0H310v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16zM213.3 833.8h16v16h-16zM229.3 818.1h-16v-15.7h16v15.7z m0-31.4h-16V771h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16V724z m0-31.3h-16V677h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16V332h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16V285z m0-31.4h-16V238h16v15.6z m0-31.3h-16v-15.7h16v15.7zM213.3 174.9h16v16h-16zM777.7 190.9h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0H568v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0H439v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16z m-32.3 0H310v-16h16.1v16z m-32.3 0h-16.1v-16h16.1v16z m-32.2 0h-16.1v-16h16.1v16zM793.8 174.9h16v16h-16zM809.8 818.1h-16v-15.7h16v15.7z m0-31.4h-16V771h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16V724z m0-31.3h-16V677h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16V332h16v15.7z m0-31.3h-16v-15.7h16v15.7z m0-31.4h-16v-15.7h16V285z m0-31.4h-16V238h16v15.6z m0-31.3h-16v-15.7h16v15.7z",
          fill: "#1e1b4b"
        )
        s.path(
          d:
            "M364.5 306.6m-44.8 0a44.8 44.8 0 1 0 89.6 0 44.8 44.8 0 1 0-89.6 0Z",
          fill: "#6366f1"
        )
        s.path(
          d:
            "M364.5 359.4c-29.1 0-52.8-23.7-52.8-52.8s23.7-52.8 52.8-52.8 52.8 23.7 52.8 52.8-23.7 52.8-52.8 52.8z m0-89.6c-20.3 0-36.8 16.5-36.8 36.8s16.5 36.8 36.8 36.8 36.8-16.5 36.8-36.8-16.5-36.8-36.8-36.8zM459.3 262.6h144.1v16H459.3zM459.3 332.2h244.1v16H459.3z",
          fill: "#1e1b4b"
        )
        s.path(
          d:
            "M364.5 516.3m-44.8 0a44.8 44.8 0 1 0 89.6 0 44.8 44.8 0 1 0-89.6 0Z",
          fill: "#6366f1"
        )
        s.path(
          d:
            "M364.5 569.1c-29.1 0-52.8-23.7-52.8-52.8s23.7-52.8 52.8-52.8 52.8 23.7 52.8 52.8-23.7 52.8-52.8 52.8z m0-89.6c-20.3 0-36.8 16.5-36.8 36.8 0 20.3 16.5 36.8 36.8 36.8s36.8-16.5 36.8-36.8c0-20.3-16.5-36.8-36.8-36.8zM459.3 472.3h144.1v16H459.3zM459.3 541.9h244.1v16H459.3z",
          fill: "#1e1b4b"
        )
        s.path(
          d: "M364.5 726m-44.8 0a44.8 44.8 0 1 0 89.6 0 44.8 44.8 0 1 0-89.6 0Z",
          fill: "#6366f1"
        )
        s.path(
          d:
            "M364.5 778.8c-29.1 0-52.8-23.7-52.8-52.8s23.7-52.8 52.8-52.8 52.8 23.7 52.8 52.8-23.7 52.8-52.8 52.8z m0-89.6c-20.3 0-36.8 16.5-36.8 36.8 0 20.3 16.5 36.8 36.8 36.8s36.8-16.5 36.8-36.8c0-20.3-16.5-36.8-36.8-36.8zM459.3 682h144.1v16H459.3zM459.3 751.6h244.1v16H459.3z",
          fill: "#1e1b4b"
        )
        s.path(d: "M359 72.4h305.2v75.9H359z", fill: "#a5b4fc")
        s.path(
          d: "M672.2 156.2H351V64.4h321.2v91.8z m-305.2-16h289.2V80.4H367v59.8z",
          fill: "#1e1b4b"
        )
        s.path(
          d:
            "M808.3 807.9m-141.7 0a141.7 141.7 0 1 0 283.4 0 141.7 141.7 0 1 0-283.4 0Z",
          fill: "#818cf8"
        )
        s.path(
          d:
            "M808.3 957.6c-82.5 0-149.7-67.1-149.7-149.7s67.1-149.7 149.7-149.7S958 725.4 958 807.9s-67.2 149.7-149.7 149.7z m0-283.4c-73.7 0-133.7 60-133.7 133.7s60 133.7 133.7 133.7S942 881.6 942 807.9s-60-133.7-133.7-133.7z",
          fill: "#1e1b4b"
        )
        s.path(
          d:
            "M810.3 727.1l26 52.5 58 8.5-42 40.9 9.9 57.8-51.9-27.3-51.9 27.3 9.9-57.8-41.9-40.9 58-8.5z",
          fill: "#FFFFFF"
        )
        s.path(
          d:
            "M872.8 901.4l-62.5-32.9-62.5 32.9 11.9-69.6-50.6-49.3 69.9-10.2 31.3-63.3 31.3 63.3 69.9 10.2-50.6 49.3 11.9 69.6z m-62.5-51l41.3 21.7-7.9-45.9 33.4-32.5L831 787l-20.6-41.8-20.7 41.8-46.1 6.7 33.4 32.5-7.9 45.9 41.2-21.7z",
          fill: "#1e1b4b"
        )
      end # end svg
    end
  end

  def render_toasts
    return unless helpers.flash.any?

    div(
      aria_live: "assertive",
      class: "pointer-events-none fixed inset-0 flex items-end px-4 py-6 sm:items-start sm:p-6 z-50"
    ) do
      div(class: "flex w-full flex-col items-center space-y-4 sm:items-end") do
        helpers.flash.each do |type, message|
          next if message.blank?

          render Components::Toast.new(
            message: message,
            type: type.to_sym
          )
        end
      end
    end
  end
end
