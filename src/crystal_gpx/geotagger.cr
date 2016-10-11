require "./parser"
require "./photo"

class CrystalGpx::Geotagger
  def initialize
    @parser = CrystalGpx::Parser.new
    @photos = Array(CrystalGpx::Photo).new

    # first positions is search within this range
    @first_search_range = Time::Span.new(0, 1, 0)
    # accept the best place within "good range"
    @good_range = Time::Span.new(0, 0, 15)
    # interpolate to quess more accurate position
    @interpolate = true # TODO implement
  end

  # Search all files and load GPX and JPG/JPEGs
  def load_path(path : String)
    Dir.glob(File.join([path, "**", "*"])).each do |f|
      if f =~ /\.gpx$/i
        load_gpx(f)
      end

      if f =~ /\.jpe?g$/i
        add_image(f)
      end
    end
  end

  def load_gpx(path : String)
    puts "Loading GPX #{path}"
    @parser.load(path)
  end

  def add_image(path : String)
    puts "Add image #{path}"
    @photos << CrystalGpx::Photo.new(path)
  end

  def match
    puts "#{@photos.size} photos + #{@parser.points.size} points"

    @photos.each do |photo|
      puts "Searching for photo #{photo.path} ..."

      point = @parser.search_for_time(
        time: photo.time.not_nil!,
        first_search_range: @first_search_range,
        good_range: @good_range,
        interpolate: @interpolate
        )
      if point
        puts "+ ... found point #{point.lat},#{point.lon} at #{point.time}, diff #{photo.time.not_nil! - point.time.not_nil!}"
        photo.set_location(lat: point.lat, lon: point.lon, ele: point.ele, direction: 0.0)
      else
        puts "- ... not found"
      end

    end
  end
end
