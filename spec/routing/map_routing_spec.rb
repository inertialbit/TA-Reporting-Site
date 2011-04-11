require 'spec_helper'

describe 'Report Maps' do
  let(:params) do
    {
      :light_brown => 'OR-WA-NV',
      :dark_brown => 'none',
      :yellow => 'CA-TX-SC',
      :gold => 'ND'      
    }
  end
  let(:path) { "/maps/light_brown/OR-WA-NV/dark_brown/none/yellow/CA-TX-SC/gold/ND/map" }
  
  describe "routing" do
    it "recognizes #map with params light_brown, dark_brown, yellow and gold" do
      { :get => path }.
        should route_to({
          :controller => 'reports',
          :action => 'map'
        }.merge!(params))
    end
    it "generates #map" do
      state_map_path(params).should eq path
    end
  end
end
