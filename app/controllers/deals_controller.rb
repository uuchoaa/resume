class DealsController < ApplicationController
  before_action :set_index_view, only: %i[ index ]
  before_action :set_kanban_view, only: %i[ kanban ]
  before_action :set_deal, only: %i[ show edit update destroy ]

  # GET /deals or /deals.json
  def index
    view.data = Deal.all
    view.current_path = request.path
    render view
  end

  # GET /deals/kanban
  def kanban
    view.data = Deal.includes(:agency, :recruter).all
    view.current_path = request.path
    render view
  end

  # GET /deals/1 or /deals/1.json
  def show
  end

  # GET /deals/new
  def new
    view.model = Deal.new
    render @view
  end

  # GET /deals/1/edit
  def edit
  end

  # POST /deals or /deals.json
  def create
    @deal = Deal.new(deal_params)

    respond_to do |format|
      if @deal.save
        format.html { redirect_to deals_path, notice: "Deal criado com sucesso!" }
        format.json { render :show, status: :created, location: @deal }
      else
        @view = Views::Deals::New.new
        @view.current_path = request.path
        @view.deal = @deal
        flash.now[:alert] = "Não foi possível criar o deal. Verifique os erros abaixo."
        format.html { render @view, status: :unprocessable_entity }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deals/1 or /deals/1.json
  def update
    respond_to do |format|
      if @deal.update(deal_params)
        # Se veio do Kanban (referer contém /kanban), redireciona para lá
        redirect_path = if request.referer&.include?("/kanban")
          kanban_deals_path
        else
          @deal
        end

        format.html { redirect_to redirect_path, notice: "Deal atualizado com sucesso!", status: :see_other }
        format.json { render :show, status: :ok, location: @deal }
      else
        flash.now[:alert] = "Não foi possível atualizar o deal. Verifique os erros abaixo."
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deals/1 or /deals/1.json
  def destroy
    @deal.destroy!

    respond_to do |format|
      format.html { redirect_to deals_path, notice: "Deal removido com sucesso!", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deal
      @deal = Deal.find(params.expect(:id))
    end

    def set_index_view
      @view = Views::Deals::Index.new
    end

    def set_kanban_view
      @view = Views::Deals::Kanban.new
    end

    # Only allow a list of trusted parameters through.
    def deal_params
      params.expect(deal: [ :agency_id, :recruter_id, :stage, :description ])
    end
end
