require "option_parser"

require "../src/crystal_gpx"

dry = false
extrapolate = false

p = CrystalGpx::Geotagger.new

OptionParser.parse! do |parser|
  parser.banner = "Usage: cr_geotag [arguments]"
  parser.on("-d", "--dry", "Perform dry run") { dry = true }
  parser.on("-e", "--extrapolate", "Use extrapolated (not real, but close enough) positions") { p.extrapolate = true }
  parser.on("-h", "--help", "Show this help") { puts parser; exit }
end

p.load_path(".")
p.match

if false == dry
  p.save
end
