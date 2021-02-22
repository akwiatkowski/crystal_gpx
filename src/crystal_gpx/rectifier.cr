require "log"

class CrystalGpx::Rectifier
  Log = ::Log.for(self)

  DEFAULT_MIN_BEARING_CHANGE   = 12.0 # degrees
  DEFAULT_MIN_DIST_FOR_BEARING = 0.10 # km
  DEFAULT_MAX_DISTANCE         =  2.0 # km
  # max distance can be as high as X percent of total distance
  DEFAULT_MAX_DISTANCE_PERCENT = 4.0

  # TODO add similar to min distance

  def initialize(
    @array : Array(CrystalGpx::Point),
    @min_bearing_change = DEFAULT_MIN_BEARING_CHANGE,
    @min_distance_for_bearing = DEFAULT_MIN_DIST_FOR_BEARING,
    @max_distance = DEFAULT_MAX_DISTANCE,
    @max_distance_percent = DEFAULT_MAX_DISTANCE_PERCENT
  )
    @new_array = Array(CrystalGpx::Point).new

    Log.info { "#{self.class}: @min_bearing_change #{@min_bearing_change}" }
    Log.info { "#{self.class}: @min_distance_for_bearing #{@min_distance_for_bearing}" }
    Log.info { "#{self.class}: @max_distance #{@max_distance}" }
    Log.info { "#{self.class}: @max_distance_percent #{@max_distance_percent}" }
  end

  def make_it_so
    @new_array.clear
    Log.info { "#{self.class}: input size #{@array.size}" }

    return nil if @array.size < 2

    last_point = @array[0]
    last_bearing = last_point.direction_to(@array[1])

    # sum distance
    total_distance = 0.0
    (1...@array.size).each do |i|
      total_distance += @array[i - 1].distance_to(@array[i])
    end

    percent_converted_distance = total_distance * @max_distance_percent.to_f / 100.0
    Log.info { "#{self.class}: percent_converted_distance #{percent_converted_distance}" }

    overall_max_distance = [@max_distance, percent_converted_distance].max
    Log.info { "#{self.class}: overall_max_distance #{overall_max_distance}" }

    (1...@array.size).each do |i|
      # check if when we ommit point it won't change bearing
      current_point = @array[i]

      current_bearing = last_point.direction_to(current_point)
      # counter direction fix
      current_bearing = 360.0 - current_bearing if current_bearing > 180.0
      current_distance = last_point.distance_to(current_point)

      bearing_abs_change = (current_bearing - last_bearing).abs

      bearing_changed = bearing_abs_change > @min_bearing_change
      distance_higher_than_min = current_distance > @min_distance_for_bearing
      distance_higher_than_max = current_distance > overall_max_distance

      should_be_added = (bearing_changed && distance_higher_than_min) || distance_higher_than_max

      if should_be_added
        Log.debug { "#{self.class}: adding, bearing_abs_change #{bearing_abs_change}, current_distance #{current_distance}" }

        @new_array << last_point

        # and use current one as last
        last_bearing = current_bearing
        last_point = current_point
      end
    end

    # add always the last one
    @new_array << @array.last

    Log.info { "#{self.class}: output size #{@new_array.size}" }
    return @new_array.uniq
  end

  def self.process(
    min_bearing_change : Float64,
    min_distance_for_bearing : Float64,
    max_distance : Float64,
    files : String,
    out_name : String
  )
    segments = Array(Array(CrystalGpx::Point)).new

    Dir[files].each do |f|
      Log.info { "#{self}: Processing file #{f}" }

      cg = CrystalGpx.load(f)
      points = cg.points

      instance = new(
        min_bearing_change: min_bearing_change,
        min_distance_for_bearing: min_distance_for_bearing,
        max_distance: max_distance,
        array: cg.points
      )

      result = instance.make_it_so
      segments << result.not_nil! if result
    end

    builder = CrystalGpx::Builder.new(segments)

    filename = "#{out_name}.gpx"
    Log.info { "#{self}: saving GPX #{filename}" }
    File.open(filename, "w") do |f|
      f << builder.to_gpx
    end

    filename = "#{out_name}.json"
    Log.info { "#{self}: saving JSON #{filename}" }
    File.open(filename, "w") do |f|
      f << builder.to_simple_json
    end

    Log.info { "#{self}: done" }
  end
end
