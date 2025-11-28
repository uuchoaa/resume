# frozen_string_literal: true

class KitchenSinkController < ApplicationController
  def index
    view = Views::KitchenSink::Index.new
    view.current_path = request.path
    render view
  end

  def model_form
    view = Views::KitchenSink::ModelForm.new
    view.current_path = request.path
    render view
  end

  def toast
    view = Views::KitchenSink::Toast.new
    view.current_path = request.path
    render view
  end
end
