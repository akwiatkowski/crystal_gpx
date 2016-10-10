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
                  point = CrystalGpx::Point.from_node(d)
                  @points << point.not_nil! if point
                end
              end
            end
          end
        end
      end
    end
  end

  getter :points

  def search_for_time(
      time : Time,
      search_range = Time::Span.new(0, 1, 0),
      good_range = Time::Span.new(0, 0, 15),
      interpolate = true,
      extrapolate = true
    )

    # preselect for faster operations
    preselected = @points.select{|p|
      abs = (p.time - time).abs
      # puts abs.inspect, p.time.inspect, time.inspect, "*"
      abs <= search_range
    }

    # check if there is one good enough
    selected = preselected.select{|p| (p.time - time).abs <= good_range}.sort{ |a,b|
      (a.time - time).abs <=> (b.time - time).abs
    }
    if selected.size > 0
      return selected[0]
    end

    # TODO
    # add interpolation to maximize accuracy
    # add extrapolation to find something, sometimes it is better
    # to have very inaccurate than no data

    return nil
  end
end
