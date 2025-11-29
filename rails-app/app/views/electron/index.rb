# frozen_string_literal: true

module Views
  module Electron
    class Index < Views::Base
      def view_template
        div(data: { controller: "scrapes" }) do
          render Components::PageHeader.new("LinkedIn Scraper Control Panel") do |header|
            header.action(
              "Scrape LinkedIn",
              primary: true,
              data: {
                action: "click->scrapes#scrape"
              }
            )
            header.action(
              "Summarize Conversation",
              data: {
                action: "click->scrapes#summarize",
                scrapes_target: "summarizeBtn"
              }
            )
            header.action(
              "Generate Responses",
              data: {
                action: "click->scrapes#generateResponses",
                scrapes_target: "generateBtn"
              }
            )
          end

          div(id: "scrape-results", class: "mt-6") do
            div(
              id: "results-container",
              class: "hidden bg-white shadow-sm rounded-lg p-6"
            ) do
              h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Latest Scrape Results" }
              
              div(id: "results-content", class: "space-y-2") do
                # Results will be inserted here by Stimulus
              end
            end

            div(id: "empty-state", class: "text-center py-12 bg-gray-50 rounded-lg") do
              svg(
                class: "mx-auto h-12 w-12 text-gray-400",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor",
                aria_hidden: "true"
              ) do |s|
                s.path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                )
              end
              h3(class: "mt-2 text-sm font-semibold text-gray-900") { "No scrapes yet" }
              p(class: "mt-1 text-sm text-gray-500") { "Click the button above to start scraping LinkedIn" }
            end
          end
        end
      end
    end
  end
end

