require "./parser"
require "./photo"

class CrystalGpx::Geotagger
  def initialize
    @parser = CrystalGpx::Parser.new
    @photos = Array(CrystalGpx::Photo).new
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

      point = @parser.search_for_time(time: photo.time.not_nil!)
      if point
        puts "+ ... found point #{point.lat},#{point.lon} at #{point.time}, diff #{photo.time.not_nil! - point.time.not_nil!}"
        photo.set_location(lat: point.lat, lon: point.lon, ele: point.ele, direction: 0.0)
      else
        puts "- ... not found"
      end

    end
  end
end
