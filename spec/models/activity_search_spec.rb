require 'spec_helper'

describe ActivitySearch do
  before(:all) do
    Activity.destroy_all
    @jan_shared = Activity.create!({
      :date_of_activity => Date.new(2010, 1, 1),
      :objective_id => 1,
      :intensity_level_id => 2,
      :ta_delivery_method_id => 3,
      :description => "January activity (w/ shared criteria)"
    })
    @jan = Activity.create!({
      :date_of_activity => Date.new(2010, 1, 2),
      :objective_id => 10,
      :intensity_level_id => 11,
      :ta_delivery_method_id => 12,
      :description => "January activity"
    })
    @feb_one = Activity.create!({
      :date_of_activity => Date.new(2010, 2, 1),
      :objective_id => 4,
      :intensity_level_id => 5,
      :ta_delivery_method_id => 6,
      :description => "February activity one"
    })
    @mar = Activity.create!({
      :date_of_activity => Date.new(2010, 3, 1),
      :objective_id => 7,
      :intensity_level_id => 8,
      :ta_delivery_method_id => 9,
      :description => "March activity"
    })
    @apr_shared = Activity.create!({
      :date_of_activity => Date.new(2010, 4, 1),
      :objective_id => 1,
      :intensity_level_id => 2,
      :ta_delivery_method_id => 3,
      :description => "April activity (w/ shared criteria)"
    })
    @feb_two = Activity.create!({
      :date_of_activity => Date.new(2010, 2, 2),
      :objective_id => 7,
      :intensity_level_id => 8,
      :ta_delivery_method_id => 9,
      :description => "February activity two"
    })
    # @jan_shared
    @jan_search_one = ActivitySearch.new({
      :start_date => Date.new(2010, 1, 1),
      :end_date => Date.new(2010, 1, 31),
      :objective_id => 1,
      :intensity_level_id => 2,
      :ta_delivery_method_id => 3,
      :keywords => "January activity (w/ shared criteria)"
    })
    @jan_search_two = ActivitySearch.new({
      :start_date => Date.new(2010, 1, 1),
      :end_date => Date.new(2010, 1, 31)
    })
    @shared_search = ActivitySearch.new({
      :start_date => Date.new(2010, 1, 1),
      :objective_id => 1,
      :intensity_level_id => 2,
      :ta_delivery_method_id => 3
    })
    @jan_mar_search = ActivitySearch.new({
      :start_date => Date.new(2010, 1, 1),
      :end_date => Date.new(2010, 3, 30)
    })
    @partial_description = ActivitySearch.new({
      :start_date => Date.new(2010, 1, 1),
      :keywords => "shared"
    })
    @blank_start = ActivitySearch.new({
      :start_date => "",
      :keywords => "shared"
    })
    @blank_end = ActivitySearch.new({
      :end_date => "",
      :keywords => "shared"
    })
  end
  after(:all) do
    Activity.destroy_all
  end
  
  it "builds conditions to find activities" do
    @jan_search_one.activities.should eq [@jan_shared]
    @jan_search_two.activities.should eq [@jan, @jan_shared]
    @shared_search.activities.should eq [@apr_shared, @jan_shared]
    @jan_mar_search.activities.should eq [@mar, @feb_two, @feb_one, @jan, @jan_shared]
    @partial_description.activities.should eq [@apr_shared, @jan_shared]
  end
  it "has a default start date" do
    @blank_start.start_date.should eq Date.current.beginning_of_month
  end
  it "has a default end date" do
    @blank_end.end_date.should eq Date.current
  end
  it "turns string dates into Date objects" do
    SummaryReport.stub(:new)
    Date.should_receive(:parse).once.with("January 1, 2010"){ Date.new(2010, 1, 1) }
    Date.should_receive(:parse).once.with("February 3, 2010"){ Date.new(2010, 2, 3) }
    ActivitySearch.new({
      :start_date => "January 1, 2010",
      :end_date => "February 3, 2010"
    })
  end
  context "Attribute Accessors" do
    before(:each) do
      @activity = ActivitySearch.new
    end
    it "start_date" do
      @activity.should respond_to :start_date
      @activity.should respond_to :start_date=
    end
    it "end_date" do
      @activity.should respond_to :end_date
      @activity.should respond_to :end_date=
    end
    it "objective_id" do
      @activity.should respond_to :objective_id
      @activity.should respond_to :objective_id=
    end
    it "intensity_level_id" do
      @activity.should respond_to :intensity_level_id
      @activity.should respond_to :intensity_level_id=
    end
    it "ta_delivery_method_id" do
      @activity.should respond_to :ta_delivery_method_id
      @activity.should respond_to :ta_delivery_method_id=
    end
    it "grant_activity_id" do
      @activity.should respond_to :grant_activity_id
      @activity.should respond_to :grant_activity_id=
    end
    it "state_id" do
      @activity.should respond_to :state_id
      @activity.should respond_to :state_id=
    end
    it "ta_category_id" do
      @activity.should respond_to :ta_category_id
      @activity.should respond_to :ta_category_id=
    end
    it "collaborating_agency_id" do
      @activity.should respond_to :collaborating_agency_id
      @activity.should respond_to :collaborating_agency_id=
    end
    it "keywords" do
      @activity.should respond_to :keywords
      @activity.should respond_to :keywords=
    end
  end
  context "Delegations" do
    before(:each) do
      @activity = ActivitySearch.new
    end
    it "delegates #states_for to :summary_report" do
      @activity.summary_report.should_receive :states_for
      @activity.states_for
    end
  end
end
