require "colorize"

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
    @interpolate = true
    # in case everything fails, GPS unit has frozen and we don't
    # have position we will use avg value from very big range
    @extrapolate = false
    @extrapolate_range = Time::Span.new(36, 0, 0)
  end

  property :extrapolate

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
    puts "Loading GPX #{path.colorize(:yellow)}"
    @parser.load(path)
  end

  def add_image(path : String)
    puts "Add image #{path.colorize(:cyan)}"
    @photos << CrystalGpx::Photo.new(path)
  end

  def match
    puts "#{@photos.size.to_s.colorize(:light_cyan)} photos + #{@parser.points.size.to_s.colorize(:light_yellow)} points"

    @photos.each_with_index do |photo, i|
      puts "Searching TIME for photo #{photo.path.colorize(:cyan)} ..."

      point_tuple = @parser.search_for_time(
        time: photo.time.not_nil!,
        first_search_range: @first_search_range,
        good_range: @good_range,
        interpolate: @interpolate,
        extrapolate: @extrapolate,
        extrapolate_range: @extrapolate_range
        )

      if point_tuple[0]
        point = point_tuple[0].not_nil!
        point_result = point_tuple[1].not_nil!

        if point_result == "interpolated"
          point = point_tuple[2].not_nil!
          puts "without interpolation found point #{point.lat.to_s.colorize(:blue)},#{point.lon.to_s.colorize(:blue)} at #{point.time.colorize(:green)}, diff #{(photo.time.not_nil! - point.time.not_nil!).to_f.to_s.colorize(:light_green)} s"
          point = point_tuple[0].not_nil!
        end
        puts "DONE #{point_result.upcase.colorize(:magenta)} found point #{point.lat.to_s.colorize(:blue)},#{point.lon.to_s.colorize(:blue)} at #{point.time.colorize(:green)}, diff #{(photo.time.not_nil! - point.time.not_nil!).to_f.to_s.colorize(:light_green)} s"

        photo.set_location(lat: point.lat, lon: point.lon, ele: point.ele, direction: 0.0)
        @photos[i] = photo # memory magic
      else
        puts "NOT FOUND".colorize(:red)
      end
    end
  end

  def save
    @photos.each do |photo|
      photo.save_location
    end
  end
end
