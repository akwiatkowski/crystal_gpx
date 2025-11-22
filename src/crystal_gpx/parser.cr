require "xml"

require "./point"

class CrystalGpx::Parser
  def initialize
    @points = Array(CrystalGpx::Point).new
  end

  def load(path : String)
    n = XML.parse(File.open(path))
    # f*** it, xpath is somehow not working
    # and I don't know why
    n.children.each do |a|
      if a.name == "gpx"
        a.children.each do |b|
          if b.name == "metadata"
            # nothing
          elsif b.name == "trk" # track
            b.children.each do |c|
              if c.name == "trkseg"
                c.children.each do |d|
                  begin
                    point = CrystalGpx::Point.from_node(n: d)
                    @points << point.not_nil! if point
                  rescue e : Time::Format::Error
                    puts "error in '#{path}' -> #{e.inspect}"
                  end
                end
              end
            end
          elsif b.name == "rte" # route
            b.children.each do |c|
              if c.name == "rtept"
                begin
                  point = CrystalGpx::Point.from_node(n: c)
                  @points << point.not_nil! if point
                rescue e : Time::Format::Error
                  puts "error in '#{path}' -> #{e.inspect}"
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
    first_search_range = Time::Span.new(0, 1, 0),
    good_range = Time::Span.new(0, 0, 15),
    interpolate = true,
    extrapolate = false,
    extrapolate_range = Time::Span.new(36, 0, 0),
  )
    # preselect for faster operations
    preselected = @points.select { |p|
      abs = (p.time - time).abs
      abs <= first_search_range
    }

    # check if there is one good enough
    selected = preselected.select { |p| (p.time - time).abs <= good_range }.sort { |a, b|
      (a.time - time).abs <=> (b.time - time).abs
    }

    if interpolate
      ip = CrystalGpx::Point.interpolate(selected, time)
      if selected.size > 0
        sp = selected[0]
      else
        sp = nil
      end

      if ip
        if sp
          if ip.not_nil!.lat != sp.not_nil!.lat || ip.not_nil!.lon != sp.not_nil!.lon
            return {ip, CrystalGpx::Geotagger::MATCH_INTERPOLATED_WITH_SELECTED, sp}
          end
        else
          return {ip, CrystalGpx::Geotagger::MATCH_INTERPOLATED, nil}
        end
      end
    end

    if selected.size > 0
      return {selected[0], CrystalGpx::Geotagger::MATCH_SELECTED, selected[0]}
    end

    # the last resort
    if extrapolate
      preselected = @points.select { |p|
        abs = (p.time - time).abs
        abs <= extrapolate_range
      }

      if preselected.size > 0
        eps = preselected.sort { |a, b|
          (a.time - time).abs <=> (b.time - time).abs
        }
        ep = eps[0]

        ip = CrystalGpx::Point.interpolate(preselected, time)

        return {ep, CrystalGpx::Geotagger::MATCH_EXTRAPOLATED, ep}
      end
    end

    # sorry :(
    return {nil, CrystalGpx::Geotagger::MATCH_NOT_FOUND, nil}
  end
end
