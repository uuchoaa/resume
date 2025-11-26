# frozen_string_literal: true

class Components::PageHeaderPreview < ComponentPreview
  preview :default,
    name: "Default",
    description: "Versão mais simples do componente, contendo apenas o título da página sem ações adicionais. Ideal para páginas informativas ou de visualização.",
    code: %(Components::PageHeader.new("Meu Título")) do
    Components::PageHeader.new("Meu Título")
  end

  preview :with_single_action,
    name: "Com Ação Secundária",
    description: "Page header com um único botão de ação secundária. Use quando houver apenas uma ação auxiliar na página, como exportar dados ou gerar relatórios.",
    code: %(Components::PageHeader.new("Gerenciar Usuários") do |header|
  header.action("Exportar", href: "/users/export")
end) do
    Components::PageHeader.new("Gerenciar Usuários") do |header|
      header.action("Exportar", href: "/users/export")
    end
  end

  preview :with_primary_action,
    name: "Com Ação Primária",
    description: "Page header destacando a ação principal com um botão primário em azul. Use quando houver uma ação principal clara que você deseja enfatizar, como criar um novo registro.",
    code: %(Components::PageHeader.new("Oportunidades") do |header|
  header.action("Nova Oportunidade", href: "/deals/new", primary: true)
end) do
    Components::PageHeader.new("Oportunidades") do |header|
      header.action("Nova Oportunidade", href: "/deals/new", primary: true)
    end
  end

  preview :with_multiple_actions,
    name: "Com Múltiplas Ações",
    description: "Page header com múltiplos botões de ação, combinando ações secundárias e primária. Perfeito para páginas com várias opções de visualização ou ações disponíveis, mantendo a ação principal em destaque.",
    code: %(Components::PageHeader.new("Pipeline de Vendas") do |header|
  header.action("📋 Lista", href: "/deals")
  header.action("📊 Kanban", href: "/deals/kanban")
  header.action("+ Novo Deal", href: "/deals/new", primary: true)
end) do
    Components::PageHeader.new("Pipeline de Vendas") do |header|
      header.action("📋 Lista", href: "/deals")
      header.action("📊 Kanban", href: "/deals/kanban")
      header.action("+ Novo Deal", href: "/deals/new", primary: true)
    end
  end
end
