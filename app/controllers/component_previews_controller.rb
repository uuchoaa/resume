# frozen_string_literal: true

class ComponentPreviewsController < ApplicationController
  helper ComponentPreviewsHelper

  def index
    preview_classes = ComponentPreview.all
    @view = Views::ComponentPreviews::Index.new(preview_classes: preview_classes)
    @view.current_path = request.path
    render @view
  end

  def show
    preview_class = find_preview_class
    variant_name = params[:variant]&.to_sym || preview_class.previews.keys.first

    @view = Views::ComponentPreviews::Show.new(
      preview_class: preview_class,
      variant_name: variant_name
    )
    @view.current_path = request.path
    render @view
  end

  private

  def find_preview_class
    "Components::#{params[:id].camelize}Preview".constantize
  end
end
