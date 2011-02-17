# == Schema Information
#
# Table name: states
#
#  id           :integer       not null, primary key
#  region_id    :integer       
#  name         :string(255)   
#  abbreviation :string(10)    
# End Schema

class State < ActiveRecord::Base
  
  include GeneralScopes
  
  belongs_to :region, :class_name => 'State'
  has_many :states, :foreign_key => :region_id, :order => 'name'
  
  has_and_belongs_to_many :activities
  
  scope :regions, :conditions => {:region_id => nil}, :include => :states, :order => 'name'
  scope :just_states, :conditions => "region_id IS NOT NULL", :order => "name"

  validates_presence_of :name
  validates_presence_of :abbreviation, :unless => Proc.new{|state| state.region_id.nil?}

  def name_or_abbrev
    name.split(' ').size > 2 ? abbreviation : name
  end
      
end
