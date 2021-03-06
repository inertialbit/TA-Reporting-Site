class ActivityMap
  
  STATE_SHAPES_FOR_MAP = YAML::load(File.open(File.join(Rails.root, 'lib', 'state_shapes.yml')))
  STATE_LABELS_FOR_MAP = YAML::load(File.open(File.join(Rails.root, 'lib', 'state_labels.yml')))
  LEVEL_COLORS = { 1 => "#F8BD0E", 2 => "#BB8519", 3 => "#7B4B23", 4 => "#FFFFCC" }
  COLORS = {
    1 => {:label => :gold, :hex => '#F8BD0E'},
    2 => {:label => :light_brown, :hex => '#BB8519'},
    3 => {:label => :dark_brown, :hex => '#7B4B23'},
    4 => {:label => :yellow, :hex => '#FFFFCC'}
  }
end