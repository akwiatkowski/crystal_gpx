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
end
