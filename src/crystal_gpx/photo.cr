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
end
