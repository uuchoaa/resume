# frozen_string_literal: true

# Add app/previews to autoload paths for component preview classes
Rails.application.config.autoload_paths += %W[#{Rails.root}/app/previews]
