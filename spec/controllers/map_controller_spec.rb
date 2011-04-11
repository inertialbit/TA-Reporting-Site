require 'spec_helper'

describe MapController do
  controller do
    include MapController
    def index
      cache_maps_and_send_png
    end
  end

  let(:state_1){ mock_model(State, {:abbreviation => 'OR'}) }
  let(:state_2){ mock_model(State, {:abbreviation => 'WA'}) }
  let(:state_3){ mock_model(State, {:abbreviation => 'KA'}) }
  let(:state_4){ mock_model(State, {:abbreviation => 'ND'}) }
  let(:intensity_1){ mock_model(IntensityLevel, {:number => 1}) }
  let(:intensity_2){ mock_model(IntensityLevel, {:number => 2}) }
  let(:intensity_3){ mock_model(IntensityLevel, {:number => 3}) }
  let(:intensity_4){ mock_model(IntensityLevel, {:number => 4}) }
  let(:intensity_levels){ [intensity_1, intensity_2, intensity_3, intensity_4] }
  
  let(:ytd_activities) do
    mock('Relation', {
      :[] => []
    })
  end
  let(:activities) do
    mock('Relation', {
      :[] => []
    })
  end
  let(:search) do
    mock_model(ActivitySearch, {
      :ytd_activities => ytd_activities,
      :activities => activities,
      :states_for => []
    })
  end
  let(:fake_params) do
    {
      :light_brown => 'none',
      :dark_brown => 'none',
      :yellow => 'none',
      :gold => 'none'
    }
  end
  
  describe "build_map_path(search_obj, path_opts={}, type=:period)" do
    before(:each) do      
      controller.stub(:build_map_path_options){ fake_params }
    end
    it "uses type to scope activities to a time period" do
      search.should_receive(:ytd_activities)
      controller.send :build_map_path, search, {}, :ytd

      search.should_receive(:activities)
      controller.send :build_map_path, search, {}, :period
    end
    it "passes search_obj to :build_map_path_options" do
      controller.should_receive(:build_map_path_options).with(search, activities, {}){ fake_params }
      controller.send :build_map_path, search, {}
    end
    it "calls the path helper" do
      controller.should_receive(:state_map_path).with(fake_params)
      controller.send :build_map_path, search, {}
    end
  end
  describe "build_map_path_options(search_obj, activities, path_opts={})" do
    before(:each) do
      IntensityLevel.stub(:order).with('number'){ intensity_levels }
      controller.stub(:color_key).with(1){ :light_brown }
      controller.stub(:color_key).with(2){ :dark_brown }
      controller.stub(:color_key).with(3){ :yellow }
      controller.stub(:color_key).with(4){ :gold }
      activities.stub(:where).with(:intensity_level_id => intensity_1.id).
        and_return(['one'])
      search.stub(:states_for).with(['one']){ [state_1, state_2] }
      activities.stub(:where).with(:intensity_level_id => intensity_2.id).
        and_return(['two'])
      search.stub(:states_for).with(['two']){ [state_2] }
      activities.stub(:where).with(:intensity_level_id => intensity_3.id).
        and_return(['three'])
      search.stub(:states_for).with(['three']){ [state_3] }
      activities.stub(:where).with(:intensity_level_id => intensity_4.id).
        and_return(['four'])
      search.stub(:states_for).with(['four']){ [state_4] }
    end
    it "it maps IntensityLevels to colors" do
      activities.stub(:where){ [] }
      controller.should_receive(:color_key).with(1)
      controller.should_receive(:color_key).with(2)
      controller.should_receive(:color_key).with(3)
      controller.should_receive(:color_key).with(4)
      
      controller.send :build_map_path_options, search, activities
    end
    it "groups activities by intensity_level for state lookups" do
      activities.should_receive(:where).with(:intensity_level_id => intensity_1.id)
      activities.should_receive(:where).with(:intensity_level_id => intensity_2.id)
      activities.should_receive(:where).with(:intensity_level_id => intensity_3.id)
      activities.should_receive(:where).with(:intensity_level_id => intensity_4.id)
      
      controller.send :build_map_path_options, search, activities
    end
    it "performs state lookups for grouped activities" do
      search.should_receive(:states_for).with(['one'])
      search.should_receive(:states_for).with(['two'])
      search.should_receive(:states_for).with(['three'])
      search.should_receive(:states_for).with(['four'])
    
      controller.send :build_map_path_options, search, activities
    end
    it "returns a hash of map colors as keys and parameterized values" do
      hash = controller.send :build_map_path_options, search, activities
      hash.should eq({
        :format => :png,
        :light_brown => 'OR-WA',
        :dark_brown => 'WA',
        :yellow => 'KA',
        :gold => 'ND'
      })
    end
  end
  describe "parameterize_states(states=[])" do
    it "returns a string of hyphen separated state abbreviations" do
      str = controller.send :parameterize_states, [state_1, state_2, state_3, state_4]
      str.should eq "OR-WA-KA-ND"
    end
  end
  describe "color_key(intensity_level_number [int 1-4])" do
    let(:colors){ [:light_brown, :dark_brown, :yellow, :gold] }
    it "returns a different color label of :light_brown, :dark_brown, :yellow or :gold for any number 1 thru 4" do
      one = controller.send :color_key, 1
      two = controller.send :color_key, 2
      three = controller.send :color_key, 3
      four = controller.send :color_key, 4
      one.should_not eq two
      one.should_not eq three
      one.should_not eq four
      two.should_not eq three
      two.should_not eq four
      three.should_not eq four
      colors.should include(one, two, three, four)
    end
    it "raises an ColorNotConfiguredError for any intensity_level_number less than 1 or greater than 4" do
      lambda{ controller.send(:color_key, 5) }.should raise_error ColorNotConfiguredError
      lambda{ controller.send(:color_key, 0) }.should raise_error ColorNotConfiguredError
    end
  end
  describe "svg_to_png(svg)" do
    let(:svg){ 'i am svg' }
    let(:resized_image_list) do
      mock('ImageList', {
        :format= => '',
        :to_blob => 'i go to blob'
      })
    end
    let(:image_list) do
      mock('ImageList', {
        :from_blob => 'i come from blob',
        :resize_to_fit => resized_image_list
      })
    end
    before(:each) do
      Magick::ImageList.stub(:new){ image_list }
    end
    it "loads from_blob svg into an instance of Magick::ImageList" do
      image_list.should_receive(:from_blob).with(svg)
      controller.send :svg_to_png, svg
    end
    it "resizes the svg to 315x300" do
      image_list.should_receive(:resize_to_fit).with(315, 300)
      controller.send :svg_to_png, svg
    end
    it "updates the format of the resized image to PNG" do
      resized_image_list.should_receive(:format=).with('PNG')
      controller.send :svg_to_png, svg
    end
    it "returns a png blob" do
      resized_image_list.should_receive(:to_blob)
      blob = controller.send :svg_to_png, svg
      blob.should eq 'i go to blob'
    end
  end
  describe "cache_maps_and_send_png" do
    let(:svg){ 'i am svg' }
    let(:png){ 'i am png'}
    before(:each) do
      controller.stub(:cache_page)
      controller.stub(:render_to_string){ svg }
      controller.stub(:svg_to_png).with(svg){ png }
      controller.stub(:send_data)
    end
    it "renders reports/map to string" do
      controller.should_receive(:render_to_string).with('reports/map')
      get :index
    end
    it "has the svg blob converted to a png blob" do
      controller.should_receive(:svg_to_png).with(svg){ png }
      get :index
    end
    it "caches the svg" do
      controller.should_receive(:cache_page).once.with(svg, '/stub_resources.svg')
      get :index, :format => :png
    end
    it "caches the png" do
      controller.should_receive(:cache_page).once.with(png, '/stub_resources.png')
      get :index, :format => :png
    end
    it "sends the png to the browser" do
      controller.should_receive(:send_data).with(png, :filename => 'map.png')
      get :index, :format => :png
    end
  end
end
