# frozen_string_literal: true

class Components::PageHeaderPreview < ComponentPreview
  preview :default,
    description: "Page header com apenas título",
    code: %(Components::PageHeader.new("Meu Título")) do
    Components::PageHeader.new("Meu Título")
  end

  preview :with_single_action,
    description: "Page header com um botão secundário",
    code: %(Components::PageHeader.new("Gerenciar Usuários") do |header|
  header.action("Exportar", href: "/users/export")
end) do
    Components::PageHeader.new("Gerenciar Usuários") do |header|
      header.action("Exportar", href: "/users/export")
    end
  end

  preview :with_primary_action,
    description: "Page header com botão primário destacado",
    code: %(Components::PageHeader.new("Oportunidades") do |header|
  header.action("Nova Oportunidade", href: "/deals/new", primary: true)
end) do
    Components::PageHeader.new("Oportunidades") do |header|
      header.action("Nova Oportunidade", href: "/deals/new", primary: true)
    end
  end

  preview :with_multiple_actions,
    description: "Page header com múltiplos botões",
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
