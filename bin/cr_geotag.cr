require "option_parser"

require "../src/crystal_gpx"

dry = false
extrapolate = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: cr_geotag [arguments]"
  parser.on("-d", "--dry", "Perform dry run") { dry = true }
  parser.on("-e", "--extrapolate", "Use extrapolated (not real, but close enough) positions") { extrapolate = true }
  # parser.on("-t NAME", "--to=NAME", "Specifies the name to salute") { |name| destination = name }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

p = CrystalGpx::Geotagger.new
p.extrapolate = extrapolate

p.load_path(".")
p.match

if false == dry
  p.save
end
