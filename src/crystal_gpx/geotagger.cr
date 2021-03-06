require "colorize"
require "yaml"

require "./parser"
require "./photo"

class CrystalGpx::Geotagger
  CONFIG_FILENAME = ".geotag.yml"

  MATCH_INTERPOLATED_WITH_SELECTED = :interpolated_with_selected
  MATCH_INTERPOLATED               = :interpolated
  MATCH_SELECTED                   = :selected
  MATCH_NOT_FOUND                  = :not_found
  MATCH_EXTRAPOLATED               = :extrapolated

  def initialize(
    @default_point : CrystalGpx::Point? = nil
  )
    @parser = CrystalGpx::Parser.new
    @photos = Array(CrystalGpx::Photo).new

    # first positions is search within this range
    @first_search_range = Time::Span.new(minutes: 1, seconds: 0)
    # accept the best place within "good range"
    @good_range = Time::Span.new(seconds: 15)
    # interpolate to quess more accurate position
    @interpolate = true
    # in case everything fails, GPS unit has frozen and we don't
    # have position we will use avg value from very big range
    @extrapolate = false
    @extrapolate_range = Time::Span.new(hours: 36)

    @hour_span = Time::Span.new(hours: 1)
    @camera_offset = 0 # in hours

    @config_path = CONFIG_FILENAME
  end

  property :extrapolate, :camera_offset

  # Search all files and load GPX and JPG/JPEGs
  def load_path(path : String)
    @config_path = File.join(path, CONFIG_FILENAME)
    load_config

    Dir.glob(File.join([path, "**", "*"])).each do |f|
      if f =~ /\.gpx$/i
        load_gpx(f)
      end

      if f =~ /\.jpe?g$/i
        add_image(f)
      end
    end
  end

  def save_config
    unless File.exists?(@config_path)
      puts "Saving config file #{@config_path.to_s.colorize(:yellow)}"
      File.open(@config_path, "w") do |file|
        YAML.dump(
          {
            "time_offset" => 0,
            "extrapolate" => true,
            "default_lat" => nil,
            "default_lon" => nil,
          },
          file
        )
      end
    end
  end

  def load_config
    if File.exists?(@config_path)
      puts "Loading config file #{@config_path.to_s.colorize(:yellow)}"
      yaml = File.open(@config_path) do |file|
        YAML.parse(file)
      end

      if yaml["time_offset"]?
        @camera_offset = yaml["time_offset"]?.to_s.to_i
        puts "Camera time offset #{@camera_offset.to_s.colorize(:yellow)} hours"
      end

      if yaml["default_lat"]?.to_s != "" && yaml["default_lon"]?.to_s != ""
        default_lat = yaml["default_lat"].to_s.to_f
        default_lon = yaml["default_lon"].to_s.to_f
        puts "Default coord #{default_lat.to_s.colorize(:yellow)},#{default_lon.to_s.colorize(:yellow)}"

        @default_point = CrystalGpx::Point.new(
          lat: default_lat.not_nil!,
          lon: default_lon.not_nil!
        )
      end

      extrapolate = yaml["extrapolate"]?.to_s
      if extrapolate == "true"
        @extrapolate = true
        puts "Extrapolate changed to #{@extrapolate.to_s.colorize(:yellow)}"
      elsif extrapolate == "false"
        @extrapolate = false
        puts "Extrapolate changed to #{@extrapolate.to_s.colorize(:yellow)}"
      end
    end
  end

  def load_gpx(path : String)
    puts "Loading GPX #{path.colorize(:yellow)}"
    @parser.load(path: path)
  end

  def add_image(path : String)
    puts "Add image #{path.colorize(:cyan)}"
    @photos << CrystalGpx::Photo.new(path)
  end

  def match
    if @default_point
      point = @default_point.not_nil!
      puts "default point #{point.lat},#{point.lon}"
    end
    puts "#{@photos.size.to_s.colorize(:light_cyan)} photos + #{@parser.points.size.to_s.colorize(:light_yellow)} points"

    @photos = @photos.sort { |a, b|
      a.path <=> b.path
    }

    @photos.each_with_index do |photo, i|
      puts "Searching TIME for photo #{(i + 1).to_s.colorize(:light_magenta)}/#{@photos.size.to_s.colorize(:light_magenta)} #{photo.path.colorize(:cyan)} at #{photo.time.inspect}"
      if photo.time.nil?
        puts "ERROR Photo has nil time #{photo.path.to_s}".colorize(:red)
        next
      end
      if @camera_offset != 0
        puts "Searching with offset #{@hour_span} hour"
      end
      point_tuple = @parser.search_for_time(
        time: photo.time.not_nil! + (@hour_span * @camera_offset),
        first_search_range: @first_search_range,
        good_range: @good_range,
        interpolate: @interpolate,
        extrapolate: @extrapolate,
        extrapolate_range: @extrapolate_range
      )

      if point_tuple[0]
        point = point_tuple[0].not_nil!
        point_result = point_tuple[1].not_nil!

        if point_result == MATCH_INTERPOLATED_WITH_SELECTED
          point = point_tuple[2].not_nil!
          puts "without interpolation found point #{point.lat.to_s.colorize(:blue)},#{point.lon.to_s.colorize(:blue)} at #{point.time.colorize(:green)}, diff #{(photo.time.not_nil! - point.time.not_nil!).to_f.to_s.colorize(:light_green)} s"
          point = point_tuple[0].not_nil!
        end
        if point_result == MATCH_EXTRAPOLATED
          point = point_tuple[2].not_nil!
          puts "closest point in extrapolation #{point.lat.to_s.colorize(:blue)},#{point.lon.to_s.colorize(:blue)} at #{point.time.colorize(:green)}, diff #{(photo.time.not_nil! - point.time.not_nil!).to_f.to_s.colorize(:light_green)} s"
          point = point_tuple[0].not_nil!
        end
        puts "DONE #{point_result.to_s.upcase.colorize(:magenta)} found point #{point.lat.to_s.colorize(:blue)},#{point.lon.to_s.colorize(:blue)} at #{point.time.colorize(:green)}, diff #{(photo.time.not_nil! - point.time.not_nil!).to_f.to_s.colorize(:light_green)} s"

        photo.set_location(lat: point.lat, lon: point.lon, ele: point.ele, direction: 0.0)
        @photos[i] = photo # memory magic
      elsif @default_point
        # save default coords
        point = @default_point.not_nil!
        puts "DEFAULT #{point.lat.to_s.colorize(:blue)},#{point.lon.to_s.colorize(:blue)}"

        photo.set_location(lat: point.lat, lon: point.lon, ele: 0, direction: 0.0)
        @photos[i] = photo
      else
        puts "NOT FOUND".colorize(:red)
      end
    end
  end

  def save
    @photos.each_with_index do |photo, i|
      puts "Saving #{(i + 1).to_s.colorize(:light_magenta)}/#{@photos.size.to_s.colorize(:light_magenta)}"
      photo.save_location
    end
  end
end
