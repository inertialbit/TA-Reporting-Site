require 'spec_helper'

describe SummaryReport do  
  let(:state_1){ mock_model(State, {:abbreviation => 'OR'}) }
  let(:state_2){ mock_model(State, {:abbreviation => 'WA'}) }
  let(:intensity_1){ mock_model(IntensityLevel, {:number => 1, :name => 'IL 1'}) }
  let(:intensity_2){ mock_model(IntensityLevel, {:number => 2, :name => 'IL 2'}) }
  let(:grant_activity_1){ mock_model(GrantActivity, {:name => 'GA 1'}) }
  let(:objective){ mock_model(Objective, {:number => 2, :name => 'Provide TA'}) }
  let(:start_date){ Date.current.beginning_of_month }
  let(:end_date){ Date.current.end_of_month }
  let(:ytd_date){ end_date.beginning_of_year }
  let(:summary_report) do
    SummaryReport.new(start_date, end_date)
  end
  
  let(:mock_first) do
    mock('First', {
      :kind_of? => true
    })
  end
  let(:mock_ytd_like) do
    mock('YTD where like', {
      :name => 'YTD where like',
      :count => 4
    })
  end
  let(:mock_ytd_where) do
    mock('YTD where', {
      :like => mock_ytd_like,
      :first => mock_first
    })
  end
  let(:ytd_activities) do
    mock('YTD Activities', {
      :where => mock_ytd_where
    })
  end
  let(:mock_period_like) do
    mock('Period where like', {
      :name => 'Period where like',
      :count => 3
    })
  end
  let(:mock_period_where) do
    mock('Period where', {
      :like => mock_period_like,
      :first => mock_first
    })
  end
  let(:period_activities) do
    mock('Period Activities', {
      :where => mock_period_where
    })
  end
  before(:each) do
    IntensityLevel.stub(:all){ [intensity_1, intensity_2] }
    GrantActivity.stub(:all){ [grant_activity_1] }
    Objective.stub(:find_by_number).with(2){ objective }
    State.stub(:abbreviated_from){ [state_1, state_2] }
    Activity.stub(:all_between).with(ytd_date, end_date){ ytd_activities }
    Activity.stub(:all_between).with(start_date, end_date){ period_activities }
  end
  describe "SummaryReport.new(start_date, end_date)" do
    it "sets @ytd_date to the first of the year for the end_date" do
      summary_report.ytd_date.should eq Date.current.beginning_of_year
    end
    it "stores @start_date and @end_date" do
      summary_report.start_date.should eq start_date
      summary_report.end_date.should eq end_date
    end
    it "loads Objective #2 as @objective" do
      summary_report.instance_variable_get("@objective").should eq objective
    end
  end
  
  describe "#state_activities(&block)" do
    it "yields a hash for every unique intensity_level <> grant_activity pair with keys :intensity_level, :grant_activity, :period_states, :period_activities, :ytd_states, :ytd_activities" do
      results = []
      summary_report.state_activities do |state_activity|
        results << state_activity
      end
      first, second = results[0], results[1]
      first[:intensity_level].should eq intensity_1
      first[:grant_activity].should eq grant_activity_1
      second[:intensity_level].should eq intensity_2
      second[:grant_activity].should eq grant_activity_1
      first[:period_states].should eq [state_1, state_2]
      first[:period_activities].should eq mock_period_like
      first[:ytd_states].should eq [state_1, state_2]
      first[:ytd_activities].should eq mock_ytd_like
    end
    it "does NOT yield if no states are associated with any activity for the intensity_level <> grant_activity pair" do
      State.stub(:abbreviated_from){ [] }
      results = []
      summary_report.state_activities do |state_activity|
        results << state_activity
      end
      results.should be_empty
    end
  end
  
  describe "#state_counts" do
    it "returns a hash of hashes whose end nodes contain period and ytd statistics for some intensity_level <> grant_activity pair" do
      results = summary_report.state_counts
      
      results[intensity_1.name][grant_activity_1.name].should eq({
        :period_activity_count => 3,
        :period_state_sentence => 'OR and WA',
        :period_state_count => 2,
        :ytd_state_count => 2
      })
    end
  end
  
  describe "#state_totals" do
    it "returns a hash of total (across intensity_levels/grant_activities) state counts and abbreviated listing" do
      mock_period_where.stub(:map).and_return([1])
      mock_period_where.stub(:kind_of?).with(ActiveRecord::Relation).at_least(:once).and_return(false)
      mock_period_where.stub(:kind_of?).with(Array).at_least(:once).and_return(true)
      mock_ytd_where.stub(:map).and_return([1,2])
      mock_ytd_where.stub(:kind_of?).with(ActiveRecord::Relation).at_least(:once).and_return(false)
      mock_ytd_where.stub(:kind_of?).with(Array).at_least(:once).and_return(true)
      State.should_receive(:abbreviated_from).with([1]){ [state_1] }
      State.should_receive(:abbreviated_from).with([1]){ [state_1] }
      State.should_receive(:abbreviated_from).with([1,2]){ [state_1, state_2] }
      summary_report.state_totals.should eq({
        :period_state_sentence => 'OR',
        :period_state_count => 1,
        :ytd_state_sentence => 'OR and WA',
        :ytd_state_count => 2
      })
    end
  end
end
