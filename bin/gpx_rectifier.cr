require "option_parser"

require "../src/crystal_gpx"

min_bearing_change = CrystalGpx::Rectifier::DEFAULT_MIN_BEARING_CHANGE
min_distance_for_bearing = CrystalGpx::Rectifier::DEFAULT_MIN_DIST_FOR_BEARING
max_distance = CrystalGpx::Rectifier::DEFAULT_MAX_DISTANCE
input_files = ""
out_name = "rectified_output"

logger = Logger.new(STDOUT)

OptionParser.parse do |parser|
  parser.banner = "Usage: gpx_rectifier [arguments]"
  parser.on("-f FILES", "--input=FILES", "Input files") { |f| input_files = f.to_s }
  parser.on("-o OUTPUT", "--output=OUTPUT", "Output files name") { |o| out_name = o.to_s }
  parser.on("-b DEGREES", "--bearing=DEGREES", "Min bearing change") { |b| min_bearing_change = b.to_f }
  parser.on("-d DISTANCE", "--distance=DISTANCE", "Max distance") { |d| max_distance = d.to_f }
  parser.on("-1", "--only-important", "Only most important") do
    min_bearing_change = 20.0
    min_distance_for_bearing = 0.3
    max_distance = 5.0
  end
  parser.on("-2", "--rather-important", "Rather important") do
    min_bearing_change = 15.0
    min_distance_for_bearing = 0.20
    max_distance = 2.0
  end
  parser.on("-3", "--regular", "Regular (not default)") do
    min_bearing_change = 10.0
    min_distance_for_bearing = 0.10
    max_distance = 1.0
  end
  parser.on("-4", "--detailed", "Detailed") do
    min_bearing_change = 8.0
    min_distance_for_bearing = 0.08
    max_distance = 1.0
  end
  parser.on("-5", "--fine", "Detailed (fine)") do
    min_bearing_change = 6.0
    min_distance_for_bearing = 0.05
    max_distance = 1.0
  end
  parser.on("-6", "--super-fine", "Detailed (super fine)") do
    min_bearing_change = 3.0
    min_distance_for_bearing = 0.03
    max_distance = 0.5
  end
  parser.on("-h", "--help", "Show this help") { puts parser; exit }
end

CrystalGpx::Rectifier.process(
  min_bearing_change: min_bearing_change,
  min_distance_for_bearing: min_distance_for_bearing,
  max_distance: max_distance,
  files: input_files,
  out_name: out_name,
  logger: logger,
)
