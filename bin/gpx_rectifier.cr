require "option_parser"

require "../src/crystal_gpx"

min_bearing_change = CrystalGpx::Rectifier::DEFAULT_MIN_BEARING_CHANGE
min_distance_for_bearing = CrystalGpx::Rectifier::DEFAULT_MIN_DIST_FOR_BEARING
max_distance = CrystalGpx::Rectifier::DEFAULT_MAX_DISTANCE
input_files = ""
out_name = "rectified_output"

OptionParser.parse do |parser|
  parser.banner = "Usage: gpx_rectifier [arguments]"
  parser.on("-f FILES", "--input=FILES", "Input files") { |f| input_files = f.to_s }
  parser.on("-o OUTPUT", "--output=OUTPUT", "Output files name") { |o| out_name = o.to_s }
  parser.on("-b DEGREES", "--bearing=DEGREES", "Min bearing change") { |b| min_bearing_change = b.to_f }
  parser.on("-d DISTANCE", "--distance=DISTANCE", "Max distance") { |d| max_distance = d.to_f }
  parser.on("-h", "--help", "Show this help") { puts parser; exit }
end

CrystalGpx::Rectifier.process(
  min_bearing_change: min_bearing_change,
  min_distance_for_bearing: min_distance_for_bearing,
  max_distance: max_distance,
  files: input_files,
  out_name: out_name,
)
