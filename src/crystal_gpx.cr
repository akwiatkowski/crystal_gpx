require "./crystal_gpx/*"

module CrystalGpx
  def self.load(path : String)
    p = CrystalGpx::Parser.new
    p.load(path)
    return p
  end
end
