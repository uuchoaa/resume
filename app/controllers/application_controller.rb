class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout false

  attr_reader :view

  def set_default_cruds_view
    @view = "Views::DefaultCruds::#{action_name.camelize}".constantize.new
    @view.current_path = request.path
  end

  before_action :set_default_cruds_view, only: %i[ index new ] # [ index show edit ]
end
