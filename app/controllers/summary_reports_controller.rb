class SummaryReportsController < ApplicationController
  
  before_filter :require_user

  private
  protected

  public
    def index
      redirect_to reports_path
    end

    def show
      @summary_report = SummaryReport.find(params[:id])
      @summary_report.dates = params
    end

    def new
      @summary_report = SummaryReport.new
    end

    def edit
      @summary_report = SummaryReport.find(params[:id])
    end

    def create
      @summary_report = SummaryReport.new(params[:summary_report])

      if @summary_report.save
        redirect_to(summary_reports_path, :notice => 'Summary Report was successfully created.') 
      else
        render :action => "new" 
      end
    end

    def update
      @summary_report = SummaryReport.find(params[:id])

      if @summary_report.update_attributes(params[:summary_report])
        redirect_to(summary_reports_path, :notice => 'Summary Report was successfully updated.')
      else
        render :action => "edit"
      end
    end

    def destroy
      @summary_report = SummaryReport.find(params[:id])
      @summary_report.destroy

      redirect_to(summary_reports_url) 
    end
end
