# frozen_string_literal: true

module ComponentPreviewsHelper
  def extract_source(preview_data)
    # Se o código foi fornecido explicitamente, usa ele
    return preview_data[:code] if preview_data[:code].present?

    # Caso contrário, tenta extrair do block
    block = preview_data[:block]
    source = block.source rescue ""
    return "" if source.blank?

    lines = source.split("\n")

    # Remove primeira linha (do) e última linha (end)
    code_lines = lines[1..-2] || []

    return "" if code_lines.empty?

    # Detecta indentação mínima (ignora linhas vazias)
    min_indent = code_lines.reject { |l| l.strip.empty? }
                           .map { |l| l[/^\s*/].length }
                           .min || 0

    # Remove indentação base
    code_lines.map { |line| line.sub(/^\s{#{min_indent}}/, "") }.join("\n")
  end

  def highlight_ruby(source_code)
    lexer = Rouge::Lexers::Ruby.new
    formatter = Rouge::Formatters::HTMLInline.new(Rouge::Themes::Monokai.new)
    formatter.format(lexer.lex(source_code)).html_safe
  end
end
