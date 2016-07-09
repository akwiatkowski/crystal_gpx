require "xml"

require "./point"

class CrystalGpx::Parser
  def initialize
    @points = Array(CrystalGpx::Point).new
  end

  def load(path : String)
    n = XML.parse(File.open(path))
    # fuck it, xpath is somehow not working
    # and I don't know why
    n.children.each do |a|
      if a.name == "gpx"
        a.children.each do |b|
          if b.name == "metadata"
            # nothing
          elsif b.name == "trk"
            b.children.each do |c|
              if c.name == "trkseg"
                c.children.each do |d|
                  @points << CrystalGpx::Point.from_node(d)
                end
              end
            end
          end
        end
      end
    end
  end

  getter :points
end
