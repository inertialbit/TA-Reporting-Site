class ColorNotConfiguredError < ArgumentError; end

module MapController
private
  def build_map_path(search, path_opts={}, type=:period)    
    activities = type == :ytd ? search.ytd_activities : search.activities
    path_opts  = build_map_path_options(search, activities, path_opts)
    state_map_path(path_opts)
  end
  
  def build_map_path_options(search, activities, path_opts={})
    IntensityLevel.order('number').each do |intensity_level|
      key            = color_key(intensity_level.number)
      conditions     = {:intensity_level_id => intensity_level.id}
      states         = search.states_for(activities.where(conditions))
      path_opts[key] = parameterize_states(states)
    end
    required_path_options(path_opts) # minimize route generation errors due to missing params
  end
  
  def parameterize_states(states=[])
    states.map(&:abbreviation).join('-')
  end
  
  def required_path_options(path_opts={})
    path_opts[:format] ||= :png
    ActivityMap::COLORS.each do |key, hash|
      path_opts[hash[:label]] = 'none' if path_opts[hash[:label]].blank?
    end
    path_opts
  end
  
  def color_key(intensity_level_number)
    begin
      ActivityMap::COLORS[intensity_level_number][:label]
    rescue NoMethodError => e
      logger.error(e.message)
      raise ColorNotConfiguredError, "A color must be configured for the intensity level with a number of: #{intensity_level_number}"
    end
  end
  
  def svg_to_png(svg)
    il             = Magick::ImageList.new
    il.from_blob(svg)
    sizedil        = il.resize_to_fit(315,300)
    sizedil.format = "PNG"
    sizedil.to_blob
  end
  
  def cache_maps_and_send_png
    svgxml     = render_to_string('reports/map')
    png        = svg_to_png(svgxml)
    
    cache_page(svgxml, request.path.gsub('.png', '.svg'))
    cache_page(png, request.path)
    
    send_data(png, :filename => 'map.png')
  end
end
