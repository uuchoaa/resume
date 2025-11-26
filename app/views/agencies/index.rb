module Views
  module Agencies
    class Index < Views::Base
      attr_reader :agencies

      def initialize(agencies:)
        @agencies = agencies
      end

      def view_template
        h1 { "Agencies" }

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
