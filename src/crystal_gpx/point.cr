require "xml"

struct CrystalGpx::Point
  @lat : Float64 = 0.0
  @lon : Float64 = 0.0
  @ele : Float64 = 0.0
  @time : Time = Time.now

  property :lat, :lon, :ele, :time

  def self.from_node(n : XML::Node)
    return nil if n["lat"]?.nil? || n["lon"]?.nil?

    s = new
    s.lat = n["lat"].to_s.to_f
    s.lon = n["lon"].to_s.to_f

    n.children.each do |c|
      if c.name == "ele"
        s.ele = c.text.to_s.to_f
      elsif c.name == "time"
        t = c.children.first.to_s
        s.time = Time.parse(t, "%Y-%m-%dT%H:%M:%S%z", Time::Kind::Local)
      end
    end

    return s
  end

  def self.interpolate(points : Array(CrystalGpx::Point), time : Time)
    # in case there is exact point
    exact = points.select{|p| p.time == time}
    return exact[0] if exact.size > 0

    # empty array, nil result
    return nil if points.size == 0

    # NOTE no check correctnes of data

    # get two points, one before, one after
    ba = points.select{|p| p.time < time}.sort{|a,b| (a.time - time).abs <=> (b.time - time).abs}
    aa = points.select{|p| p.time > time}.sort{|a,b| (a.time - time).abs <=> (b.time - time).abs}

    # if not enough data, no before/after return nil
    return nil if ba.size == 0 || aa.size == 0

    before = ba[0]
    after = aa[0]

    point = CrystalGpx::Point.new
    point.time = time
    point.lat = before.lat
    point.lat += (after.lat - before.lat) * ((time - before.time).to_f / (after.time - before.time).to_f)

    point.lon = before.lon
    point.lon += (after.lon - before.lon) * (time - before.time).to_f / (after.time - before.time).to_f

    point.ele = before.ele
    point.ele += (after.ele - before.ele) * (time - before.time).to_f / (after.time - before.time).to_f

    return point
  end
end
