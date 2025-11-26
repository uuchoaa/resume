module Views
  module Deals
    class Index < Views::DefaultCruds::Index
      def render_page_header
        render Components::PageHeader.new(page_title) do |header|
          header.action("📊 Kanban", href: kanban_deals_path)
          header.action("+ Novo", href: new_deal_path, primary: true)
        end
      end
    end
  end
end
