require "option_parser"

require "../src/crystal_gpx"

dry = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: cr_geotag [arguments]"
  parser.on("-d", "--dry", "Perform dry run") { dry = true }
  parser.on("-t NAME", "--to=NAME", "Specifies the name to salute") { |name| destination = name }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

puts dry

p = CrystalGpx::Geotagger.new
#p.load_path(".")
#p.match
