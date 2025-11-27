# frozen_string_literal: true

class KitchenSinkController < ApplicationController
  skip_before_action :set_default_cruds_view

  def model_form
    view = Views::KitchenSink::ModelForm.new
    view.current_path = request.path
    render view
  end
end
