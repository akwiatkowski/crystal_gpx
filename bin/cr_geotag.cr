require "option_parser"

require "../src/crystal_gpx"

dry = false
extrapolate = false

p = CrystalGpx::Geotagger.new

OptionParser.parse! do |parser|
  parser.banner = "Usage: cr_geotag [arguments]"
  parser.on("-d", "--dry", "Perform dry run") { dry = true }
  parser.on("-e", "--extrapolate", "Use extrapolated (not real, but close enough) positions") { p.extrapolate = true }

  # GPS units should use timezone, but I'm not sure 100%
  # if every software is doing it ok
  # Even if not, this options are not usable now
  # Localtime is default
  #parser.on("-gu", "--gps-utc", "GPS store time in UTC") { p.gps_utc! }
  #parser.on("-gl", "--gps-local", "GPS store time in local timezone") { p.gps_local! }

  # parser.on("-t NAME", "--to=NAME", "Specifies the name to salute") { |name| destination = name }
  parser.on("-h", "--help", "Show this help") { puts parser; exit }
end

p.load_path(".")
p.match

if false == dry
  p.save
end
