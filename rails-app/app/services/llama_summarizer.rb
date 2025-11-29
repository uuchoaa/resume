# frozen_string_literal: true

class LlamaSummarizer
  LLAMA_CLI_PATH = 'llama-cli' # Installed via brew, available in PATH
  MODEL_PATH = '/Users/dev/workspace/llama-models/mistral-7b-instruct-v0.2.Q4_K_M.gguf'
  
  def self.summarize(conversation_data)
    new(conversation_data).summarize
  end

  def self.generate_responses(conversation_data)
    new(conversation_data).generate_responses
  end
  
  def initialize(conversation_data)
    @conversation_data = conversation_data
  end
  
  def summarize
    prompt = build_prompt
    
    puts "🤖 Calling llama.cpp to summarize conversation..."
    
    # Chama llama-cli via subprocess (redireciona stderr para /dev/null para limpar logs)
    output = `#{LLAMA_CLI_PATH} \
      -m #{MODEL_PATH} \
      -p "#{prompt.gsub('"', '\"')}" \
      -n 200 \
      --temp 0.7 \
      -no-cnv \
      --repeat-penalty 1.1 \
      2>/dev/null`
    
    # Extrai apenas a resposta (remove logs e metadados)
    summary = extract_summary(output, prompt)
    
    puts "✅ Summary generated: #{summary[0..100]}..."
    
    summary
  rescue => e
    puts "❌ Error generating summary: #{e.message}"
    "Error: Unable to generate summary - #{e.message}"
  end

  def generate_responses
    # Pega apenas as últimas 2 mensagens
    last_messages = @conversation_data[:messages].last(2)
    
    prompt = build_responses_prompt(last_messages, @conversation_data[:contact])
    
    puts "🤖 Generating response options..."
    
    output = `#{LLAMA_CLI_PATH} \
      -m #{MODEL_PATH} \
      -p "#{prompt.gsub('"', '\"')}" \
      -n 150 \
      --temp 0.8 \
      -no-cnv \
      --repeat-penalty 1.1 \
      2>/dev/null`
    
    # Parse as duas opções
    responses = parse_responses(output)
    
    puts "✅ Generated #{responses.length} response options"
    
    responses
  rescue => e
    puts "❌ Error generating responses: #{e.message}"
    {
      affirmative: "Error: Unable to generate response",
      negative: "Error: Unable to generate response"
    }
  end
  
  private
  
  def build_prompt
    contact_name = @conversation_data[:contact][:name] || 'the contact'
    messages_text = @conversation_data[:messages].map do |msg|
      "#{msg[:sender]}: #{msg[:text]}"
    end.join("\n")
    
    <<~PROMPT
      Summarize this LinkedIn recruiting conversation between #{contact_name} and the candidate.
      
      Focus on:
      - Job opportunity details
      - Company and role
      - Requirements mentioned
      - Salary/compensation if discussed
      - Next steps or action items
      
      Messages:
      #{messages_text}
      
      Provide a concise, professional summary in 2-3 sentences.
    PROMPT
  end

  def build_responses_prompt(last_messages, contact)
    contact_name = contact[:name] || 'the recruiter'
    
    messages_text = last_messages.map do |msg|
      "#{msg[:sender]}: #{msg[:text]}"
    end.join("\n")
    
    <<~PROMPT
      Generate response options for LinkedIn recruiting conversations.
      
      Example 1:
      Messages:
      Sarah: Hi! We have a Senior Rails position at our startup. Interested?
      John: Could you share more details about the role?
      
      AFFIRMATIVE: Yes, I'm interested! I'd love to learn more about the position and discuss how my experience aligns with your needs.
      NEGATIVE: Thank you for reaching out, but I'm not looking for new opportunities at this time. Best of luck with your search!
      
      Example 2:
      Messages:
      Mike: We offer $120k base + equity. Remote work available.
      Lisa: That sounds interesting. What's the tech stack?
      
      AFFIRMATIVE: The compensation and remote setup look great! I'd like to schedule a call to discuss the technical details and team structure.
      NEGATIVE: I appreciate the offer, but I've decided to pursue other directions in my career. Thanks for considering me!
      
      Now generate responses for this conversation:
      Messages:
      #{messages_text}
      
      AFFIRMATIVE:
      NEGATIVE:
    PROMPT
  end

  def parse_responses(output)
    # Limpa o output
    cleaned = output.strip
    
    # Tenta extrair as respostas
    affirmative = nil
    negative = nil
    
    if cleaned =~ /AFFIRMATIVE:\s*(.+?)(?=NEGATIVE:|$)/m
      affirmative = $1.strip
    end
    
    if cleaned =~ /NEGATIVE:\s*(.+?)$/m
      negative = $1.strip
    end
    
    # Fallback se não conseguir parsear
    unless affirmative && negative
      # Tenta split por linhas e pegar primeira e segunda
      lines = cleaned.split("\n").reject(&:empty?)
      affirmative = lines[0] || "I'm interested! Can we discuss further?"
      negative = lines[1] || "Thank you, but I'm not interested at this time."
    end
    
    {
      affirmative: affirmative,
      negative: negative
    }
  end
  
  def extract_summary(output, prompt)
    # Remove o prompt da saída (às vezes llama-cli ecoa o prompt)
    cleaned = output.gsub(prompt, '').strip
    
    # Remove linhas de log/debug do llama.cpp
    lines = cleaned.split("\n")
    
    # Pega apenas linhas que parecem ser a resposta do modelo
    # (ignora linhas que começam com print_info, load, common_, etc)
    response_lines = lines.reject do |line|
      line.match?(/^(print_info|load|common_|llama_|ggml_|system_info|sampler|generate|main:|build:|==|>|\s*-|\t|\.{3,})/i) ||
      line.strip.empty?
    end
    
    # Junta e limpa
    response = response_lines.join("\n").strip
    
    # Se ainda tiver muito texto (mais que o esperado), pega só os últimos parágrafos
    if response.length > 1000
      # Pega tudo após o último "Provide a concise" ou similares
      if response =~ /(Provide a concise.*?\n\n)(.+)/m
        response = $2.strip
      else
        # Fallback: pega últimas 500 chars
        response = response[-500..-1]
      end
    end
    
    # Remove marcadores de fim se existirem
    response.gsub(/\[end of text\].*$/im, '').strip
  end
end

