require "logger"

class CrystalGpx::Rectifier
  DEFAULT_MIN_BEARING_CHANGE = 15.0 # degrees
  DEFAULT_MIN_DIST_FOR_BEARING = 0.2 # km
  DEFAULT_MAX_DISTANCE = 2.0 # km

  def initialize(
    @array : Array(CrystalGpx::Point),
    @min_bearing_change = DEFAULT_MIN_BEARING_CHANGE,
    @min_distance_for_bearing = DEFAULT_MIN_DIST_FOR_BEARING,
    @max_distance = DEFAULT_MAX_DISTANCE,
    @logger = Logger.new(STDOUT)
  )
    @new_array = Array(CrystalGpx::Point).new
  end

  def make_it_so
    @new_array.clear
    @logger.info("#{self.class}: input size #{@array.size}")

    return nil if @array.size < 2

    last_point = @array[0]
    last_bearing = last_point.direction_to(@array[1])

    (1...@array.size).each do |i|
      # check if when we ommit point it won't change bearing
      current_point = @array[i]

      current_bearing = last_point.direction_to(current_point)
      current_distance = last_point.distance_to(current_point)

      bearing_abs_change = (current_bearing - last_bearing).abs

      bearing_changed = bearing_abs_change > @min_bearing_change
      distance_higher_than_min = current_distance > @min_distance_for_bearing
      distance_higher_than_max = current_distance > @max_distance
      is_last_point = (i == (@array.size - 1))

      should_be_added = is_last_point || (bearing_changed && distance_higher_than_min) || distance_higher_than_max

      if should_be_added
        @new_array << last_point

        # and use current one as last
        last_bearing = last_point.direction_to(current_point)
        last_point = current_point
      end
    end

    @logger.info("#{self.class}: output size #{@new_array.size}")
    return @new_array
  end

  def self.process(
    min_bearing_change : Float64,
    min_distance_for_bearing : Float64,
    max_distance : Float64,
    files : String,
    out_name : String,
  )
    segments = Array(Array(CrystalGpx::Point)).new

    Dir[files].each do |f|
      cg = CrystalGpx.load(f)
      points = cg.points

      instance = new(
        min_bearing_change: min_bearing_change,
        min_distance_for_bearing: min_distance_for_bearing,
        max_distance: max_distance,
        array: cg.points
      )

      segments << instance.make_it_so.not_nil!
    end

    builder = CrystalGpx::Builder.new(segments)

    File.open("#{out_name}.gpx", "w") do |f|
      f << builder.to_gpx
    end

    File.open("#{out_name}.json", "w") do |f|
      f << builder.to_simple_json
    end
  end
end
