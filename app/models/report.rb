# == Schema Information
#
# Table name: reports
#
#  id                   :integer       not null, primary key
#  name                 :string(255)   
#  include_descriptions :boolean       
#  begin_date           :date          
#  end_date             :date          
#  created_at           :datetime      
#  updated_at           :datetime      
# End Schema

class Report < ActiveRecord::Base
  attr_reader :csv
  
  has_and_belongs_to_many :objectives
  
  def export_as_csv
    activities = Activity.find(:all, :conditions => [
      "date_of_activity LIKE ?",
      "%#{self.month.to_s[0..3]}-#{self.month.to_s[5..6]}%"
    ])
    @csv = FasterCSV.dump(activities) unless activities.empty?
  end
end