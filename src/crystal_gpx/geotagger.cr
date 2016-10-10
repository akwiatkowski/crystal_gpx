require "./parser"

class CrystalGpx::Geotagger
  def initialize
    @parser = CrystalGpx::Parser.new
  end

  def load_gpx(path : String)
    @parser.load(path)
  end
end
