class AgenciesController < ApplicationController
  before_action :set_agency, only: %i[ show edit update destroy ]
  before_action :set_default_cruds_view, only: %i[ index ] # [ index show edit ]

  def set_default_cruds_view
    @view = "Views::DefaultCruds::#{action_name.camelize}".constantize.new
    @view.current_path = request.path
    @view.page_title = "Agencies"
  end

  attr_reader :view

  # GET /agencies or /agencies.json
  def index
    view.data = Agency.all
    render view
  end

  # GET /agencies/1 or /agencies/1.json
  def show
  end

  # GET /agencies/new
  def new
    @agency = Agency.new
  end

  # GET /agencies/1/edit
  def edit
  end

  # POST /agencies or /agencies.json
  def create
    @agency = Agency.new(agency_params)

    respond_to do |format|
      if @agency.save
        format.html { redirect_to @agency, notice: "Agency was successfully created." }
        format.json { render :show, status: :created, location: @agency }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agencies/1 or /agencies/1.json
  def update
    respond_to do |format|
      if @agency.update(agency_params)
        format.html { redirect_to @agency, notice: "Agency was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @agency }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agencies/1 or /agencies/1.json
  def destroy
    @agency.destroy!

    respond_to do |format|
      format.html { redirect_to agencies_path, notice: "Agency was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agency
      @agency = Agency.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def agency_params
      params.expect(agency: [ :name ])
    end
end
