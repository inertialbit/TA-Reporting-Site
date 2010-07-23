class ReportsController < ApplicationController
  def index
    @activities = Activity.all
    @report = @activities.to_csv(:except => [:created_at, :updated_at])
  end
  
  def new
    @report = Report.new
  end
end
