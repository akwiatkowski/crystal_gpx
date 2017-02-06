require "xml"

struct CrystalGpx::Point
  D2R = Math::PI / 180.0

  @lat : Float64 = 0.0
  @lon : Float64 = 0.0
  @ele : Float64 = 0.0
  @time : Time = Time.now

  property :lat, :lon, :ele, :time

  def initialize
  end

  def initialize(@lat : Float64, @lon : Float64)
  end

  def self.from_node(n : XML::Node, time_type = Time::Kind::Local)
    return nil if n["lat"]?.nil? || n["lon"]?.nil?

    s = new
    s.lat = n["lat"].to_s.to_f
    s.lon = n["lon"].to_s.to_f

    n.children.each do |c|
      if c.name == "ele"
        s.ele = c.text.to_s.to_f
      elsif c.name == "time"
        t = c.children.first.to_s
        s.time = Time.parse(t, "%Y-%m-%dT%H:%M:%S%z", time_type)
      end
    end

    return s
  end

  def self.interpolate(points : Array(CrystalGpx::Point), time : Time)
    # in case there is exact point
    exact = points.select { |p| p.time == time }
    return exact[0] if exact.size > 0

    # empty array, nil result
    return nil if points.size == 0

    # NOTE no check correctnes of data

    # get two points, one before, one after
    ba = points.select { |p| p.time < time }.sort { |a, b| (a.time - time).abs <=> (b.time - time).abs }
    aa = points.select { |p| p.time > time }.sort { |a, b| (a.time - time).abs <=> (b.time - time).abs }

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

  def self.distance(lat1, lon1, lat2, lon2)
    # http://stackoverflow.com/questions/365826/calculate-distance-between-2-gps-coordinates
    dlong = (lon2 - lon1) * D2R
    dlat = (lat2 - lat1) * D2R
    a = (Math.sin(dlat / 2.0) ** 2.0) + Math.cos(lat1 * D2R) * Math.cos(lat2 * D2R) * (Math.sin(dlong / 2.0) ** 2.0)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a))
    d = 6367.0 * c

    return d
  end

  def self.distance(point1 : CrystalGpx::Point, point2 : CrystalGpx::Point)
    return distance(
      lat1: point1.lat,
      lon1: point1.lon,
      lat2: point2.lat,
      lon2: point2.lon
    )
  end

  def distance_to(other_point : CrystalGpx::Point)
    return self.class.distance(point1: self, point2: other_point)
  end

  def distance_to(other_lat : Float64, other_lon : Float64)
    return self.class.distance(
      lat1: self.lat,
      lon1: self.lon,
      lat2: other_lat,
      lon2: other_lon
    )
  end

  # return direction in degrees
  #
  # before normalize
  # south = -90 -> 180
  # north = 90 -> 0
  # east = 0 -> 90
  # west = 180 -> 270
  #
  # after normalize
  # south = 180
  # north = 0
  # east = 90
  # west = 270
  def self.direction(lat1, lon1, lat2, lon2)
    # http://stackoverflow.com/questions/9566069/how-to-calculate-angle-between-two-geographical-gps-coordinates
    dy = lat2 - lat1
    dx = Math.cos(D2R * lat1) * (lon2 - lon1)
    angle = Math.atan2(dy, dx)
    d = angle / D2R
    # normalize
    return (360 + 90 - d) % 360
  end

  def self.direction(point1 : CrystalGpx::Point, point2 : CrystalGpx::Point)
    return direction(
      lat1: point1.lat,
      lon1: point1.lon,
      lat2: point2.lat,
      lon2: point2.lon
    )
  end

  def direction_to(other_point : CrystalGpx::Point)
    return self.class.direction(point1: self, point2: other_point)
  end

  def direction_to(other_lat : Float64, other_lon : Float64)
    return self.class.direction(
      lat1: self.lat,
      lon1: self.lon,
      lat2: other_lat,
      lon2: other_lon
    )
  end

  def self.direction_to_human(d : Float64) : String
    h = 45.0 / 2.0
    dp = (d / h).floor.to_i

    return case dp
    when      0 then "N"
    when 1, 2   then "NE"
    when 3, 4   then "E"
    when 5, 6   then "SE"
    when 7, 8   then "S"
    when 9, 10  then "SW"
    when 11, 12 then "W"
    when 13, 14 then "NW"
    when     15 then "N"
    else
      raise "direction is wrong"
    end
  end
end
