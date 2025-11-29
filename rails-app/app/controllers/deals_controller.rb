class DealsController < CrudController
  skip_before_action :verify_authenticity_token

  # GET /deals/kanban
  def index
    view = Views::Deals::Kanban.new
    view.current_path = request.path
    view.data = Deal.includes(:agency, :recruter).all
    view.current_path = request.path
    render view
  end

  def summarize
    summary = LlamaSummarizer.summarize(params.permit!.to_h.with_indifferent_access)
    render json: {
      status: "success",
      summary: summary
    }, status: :ok
  rescue StandardError => e
    puts "❌ Error summarizing: #{e.message}"
    render json: {
      status: "error",
      message: e.message
    }, status: :unprocessable_entity
  end

  # POST /deals/find_or_create
  def find_or_create
    puts "=" * 80
    puts "📡 Received scrape data from Electron:"
    puts JSON.pretty_generate(params.permit!.to_h)
    puts "=" * 80

    scraped_data = {
      text: params[:text],
      total_paragraphs: params[:totalParagraphs],
      timestamp: params[:timestamp],
      success: params[:success]
    }

    # Broadcast to ActionCable
    ActionCable.server.broadcast(
      "scrapes",
      scraped_data
    )

    render json: {
      status: "success",
      message: "Data received and broadcasted",
      data: scraped_data
    }, status: :ok
  rescue StandardError => e
    puts "❌ Error processing scrape: #{e.message}"
    render json: {
      status: "error",
      message: e.message
    }, status: :unprocessable_entity
  end

  # POST /deals/generate_responses
  def generate_responses
    puts "🤖 Received generate_responses request"
    
    conversation_data = params.permit!.to_h.with_indifferent_access
    
    # Chama o LlamaSummarizer para gerar respostas
    responses = LlamaSummarizer.generate_responses(conversation_data)
    
    render json: {
      status: "success",
      responses: responses
    }, status: :ok
  rescue StandardError => e
    puts "❌ Error generating responses: #{e.message}"
    puts e.backtrace.first(5)
    render json: {
      status: "error",
      message: e.message
    }, status: :unprocessable_entity
  end
end
