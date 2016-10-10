require "./parser"
require "./photo"

class CrystalGpx::Geotagger
  def initialize
    @parser = CrystalGpx::Parser.new
    @photos = Array(CrystalGpx::Photo).new
  end

  def load_gpx(path : String)
    @parser.load(path)
  end

  def add_image(path : String)
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
