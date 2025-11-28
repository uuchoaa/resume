# frozen_string_literal: true

class CrudController < ApplicationController
  before_action :set_model_class
  before_action :set_resource, only: [ :show, :edit, :update, :destroy ]

  # GET /resources
  def index
    view = Views::DefaultCruds::Index.new
    view.current_path = request.path
    view.data = model_class.all
    render view
  end

  # GET /resources/1
  def show
    # TODO: implementar view padrão
  end

  # GET /resources/new
  def new
    @resource = model_class.new
    view = Views::DefaultCruds::New.new
    view.current_path = request.path
    view.model = @resource
    render view
  end

  # GET /resources/1/edit
  def edit
    # TODO: implementar view padrão
  end

  # POST /resources
  def create
    @resource = model_class.new(resource_params)

    respond_to do |format|
      if @resource.save
        format.html do
          redirect_to polymorphic_path(model_class),
            notice: I18n.t("crud.create.success", model: model_class.model_name.human)
        end
        format.json { render json: @resource, status: :created, location: @resource }
      else
        view = Views::DefaultCruds::New.new
        view.current_path = request.path
        view.model = @resource
        flash.now[:alert] = I18n.t("crud.create.error", model: model_class.model_name.human)
        format.html { render view, status: :unprocessable_entity }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html do
          redirect_to polymorphic_path(model_class),
            notice: I18n.t("crud.update.success", model: model_class.model_name.human)
        end
        format.json { render json: @resource, status: :ok, location: @resource }
      else
        # TODO: renderizar view de edit
        flash.now[:alert] = I18n.t("crud.update.error", model: model_class.model_name.human)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  def destroy
    @resource.destroy!

    respond_to do |format|
      format.html do
        redirect_to polymorphic_path(model_class),
          notice: I18n.t("crud.destroy.success", model: model_class.model_name.human)
      end
      format.json { head :no_content }
    end
  end

  private

  # Infere o model class a partir do nome do controller
  # Ex: AgenciesController → Agency
  def set_model_class
    @model_class = controller_name.classify.constantize
  end

  def model_class
    @model_class
  end

  def set_resource
    @resource = model_class.find(params[:id])
  end

  # Permite todos os atributos exceto timestamps e id
  def resource_params
    permitted_attributes = model_class.column_names - %w[id created_at updated_at]
    params.require(model_class.model_name.param_key).permit(*permitted_attributes)
  end

  # Torna disponível para as views
  helper_method :model_class
end
