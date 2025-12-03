class AgenciesController < ApplicationController
  layout :false

  def new
    agency = Agency.new
    render Views::Agencies::New.new(agency)
  end

  def index
  end
end
