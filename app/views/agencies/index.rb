module Views
  module Agencies
    class Index < Views::Base
      attr_reader :agencies

      def initialize(agencies:, request:)
        @request = request
        @agencies = agencies
      end

      def page_title = "Agencias"

      def view_template
        ul do
          agencies.each do |agency|
            li do
              a(href: "/agencies/#{agency.id}") { agency.name }
            end
          end
        end
      end
    end
  end
end
