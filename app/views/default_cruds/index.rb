module Views
  module DefaultCruds
    class Index < Views::Base
      def view_template(&)
        ul do
          data_collection.each do |agency|
            li do
              a(href: "/agencies/#{agency.id}") { agency.name }
            end
          end
        end
      end
    end
  end
end
