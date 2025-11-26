# frozen_string_literal: true

class ComponentPreview
  class << self
    def preview(name, description: nil, code: nil, &block)
      previews[name] = {
        description: description,
        block: block,
        code: code
      }
    end

    def previews
      @previews ||= {}
    end

    def component_name
      name.demodulize.gsub("Preview", "")
    end

    def all
      # Força o carregamento de todos os previews
      Dir[Rails.root.join("app/previews/**/*_preview.rb")].each do |file|
        require_dependency file
      end
      descendants
    end
  end
end
