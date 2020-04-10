class CrystalGpx::Builder
  def initialize(array : Array(CrystalGpx::Point))
    @segments = [array].as(Array(Array(CrystalGpx::Point)))
  end

  def initialize(@segments : Array(Array(CrystalGpx::Point)))
  end

  XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>"
  GPX_HEADER = "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" >"

  TRK_OPEN = "<trk>"
  TRK_CLOSE = "</trk>"

  SEGMENT_OPEN = "<trkseg>"
  SEGMENT_CLOSE = "</trkseg>"

  GPX_CLOSE = "</gpx>"

  def segment_to_gpx(array)
    return String.build do |s|
      s << SEGMENT_OPEN

      array.each do |point|
        s << "<trkpt lat=\"#{point.lat}\" lon=\"#{point.lon}\">"

        if point.ele
          s << "<ele>#{point.ele}</ele>"
        end

        # TODO add later
        if point.time
          # <time>2019-08-07T03:32:04Z</time>
          #s << "<time>point.time.to_s</time>"
        end

        s << "</trkpt>"
      end

      s << SEGMENT_CLOSE
    end
  end

  def to_gpx
    return String.build do |s|
      s << XML_HEADER
      s << GPX_HEADER

      s << TRK_OPEN

      @segments.each do |array|
        s << segment_to_gpx(array)
      end

      s << TRK_CLOSE
      s << GPX_CLOSE
    end
  end
end
