require "../src/crystal_gpx"

p = CrystalGpx::Geotagger.new
p.load_path(".")
p.match
