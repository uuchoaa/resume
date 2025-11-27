class RecrutersController < ApplicationController
  before_action :set_recruter, only: %i[ show edit update destroy ]

  # GET /recruters or /recruters.json
  def index
    view.data = Recruter.all
    render view
  end

  # GET /recruters/1 or /recruters/1.json
  def show
  end

  # GET /recruters/new
  def new
    view.model = Recruter.new
    render view
  end

  # GET /recruters/1/edit
  def edit
  end

  # POST /recruters or /recruters.json
  def create
    @recruter = Recruter.new(recruter_params)

    respond_to do |format|
      if @recruter.save
        format.html { redirect_to @recruter, notice: "Recruter was successfully created." }
        format.json { render :show, status: :created, location: @recruter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recruter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recruters/1 or /recruters/1.json
  def update
    respond_to do |format|
      if @recruter.update(recruter_params)
        format.html { redirect_to @recruter, notice: "Recruter was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @recruter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recruter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recruters/1 or /recruters/1.json
  def destroy
    @recruter.destroy!

    respond_to do |format|
      format.html { redirect_to recruters_path, notice: "Recruter was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recruter
      @recruter = Recruter.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def recruter_params
      params.expect(recruter: [ :agency_id, :name, :linkedin_chat_url ])
    end
end
