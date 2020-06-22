require "option_parser"

require "../src/crystal_gpx"

dry = false
initialize_config = false
extrapolate = false

default_lat = nil
default_lon = nil
extrapolate = false

OptionParser.parse do |parser|
  parser.banner = "Usage: cr_geotag [arguments]"
  parser.on("-n", "--initialize", "Initialize empty config file") { initialize_config = true }
  parser.on("-d", "--dry", "Perform dry run") { dry = true }
  parser.on("-e", "--extrapolate", "Use extrapolated (not real, but close enough) positions") { extrapolate = true }
  parser.on("-l LAT", "--lat=LAT", "Use default lat") { |lat| default_lat = lat.to_f }
  parser.on("-m LON", "--lon=LON", "Use default lon") { |lon| default_lon = lon.to_f }
  parser.on("-h", "--help", "Show this help") { puts parser; exit }
end

# store default point for force update coords
if default_lat && default_lon
  point = CrystalGpx::Point.new(
    lat: default_lat.not_nil!,
    lon: default_lon.not_nil!
  )
  p = CrystalGpx::Geotagger.new(
    default_point: point
  )
else
  p = CrystalGpx::Geotagger.new
end

# assign things
p.extrapolate = extrapolate

# run
if initialize_config
  p.save_config
else
  # run all the stuff
  p.load_path(".")
  p.match

  if false == dry
    p.save
  end
end
