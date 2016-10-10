struct CrystalGpx::Photo
  @@command = "exiv2"
  @@timestamp_key = "Image timestamp"

  @time : (Time | Nil)

  getter :path, :time

  def initialize(@path : String)
    @exif = Hash(String, String).new

    get_exif
  end

  def get_exif
    command = "#{@@command} #{@path}"
    result = `#{command}`

    result.split(/\n/).each do |l|
      if l.strip =~ /([^:]+)\:(.+)/
        @exif[$1.to_s.strip] = $2.to_s.strip
      end
    end

    if @exif[@@timestamp_key]?
      # "2016:10:10 07:04:33"
      @time = Time.parse(@exif[@@timestamp_key], "%Y:%m:%d %H:%M:%S", Time::Kind::Local)
    end
  end

  def command_to_update_exif(path, key, value)
    return "exiv2 -M\"set #{key} #{value}\" #{path}"
  end

  def update_exif(path, key, value)
    c = command_to_update_exif(path, key, value)
    puts c
    `#{c}`
  end

  def convert_degree_to_exiv_string(degree : Float64) : String
    d = degree.abs.to_i
    m = ((degree - d.to_f) * 60.0).to_i
    s = ((degree - d.to_f - (m.to_f / 60.0)) * 3600.0).to_f

    x = 20
    ss = "#{(s * x.to_f).round.to_i}/#{x}"

    return "#{d}/1 #{m}/1 #{ss}"
  end

  def set_location(lat : Float64, lon : Float64, ele : Float64, direction = 0.0)
    # http://www.exiv2.org/tags.html

    update_exif(@path, "Exif.GPSInfo.GPSVersionID", "2 2 0 0")

    lat_ref = (lat < 0.0) ? "South" : "North"
    update_exif(@path, "Exif.GPSInfo.GPSLatitudeRef", lat_ref)

    lon_ref = (lon < 0.0) ? "W" : "E"
    update_exif(@path, "Exif.GPSInfo.GPSLongitudeRef", lon_ref)

    update_exif(@path, "Exif.GPSInfo.GPSLatitude", convert_degree_to_exiv_string(lat) )
    update_exif(@path, "Exif.GPSInfo.GPSLongitude", convert_degree_to_exiv_string(lon) )
    update_exif(@path, "Exif.GPSInfo.GPSAltitude", "#{ele.to_i}/1")
    # update_exif(@path, "Exif.GPSInfo.GPSImgDirectionRef", "True direction")
    # update_exif(@path, "Exif.GPSInfo.GPSImgDirection", "0/1") # direction
    update_exif(@path, "Exif.GPSInfo.GPSMapDatum", "WGS-84")
  end
end
