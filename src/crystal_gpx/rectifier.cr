require "logger"

class CrystalGpx::Rectifier
  def initialize(
    @array : Array(CrystalGpx::Point),
    @min_bearing_change = 15.0,
    @min_distance_change = 0.2, # in km
    @max_distance_change = 2.0, # in km
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
      distance_higher_than_min = current_distance > @min_distance_change
      distance_higher_than_max = current_distance > @max_distance_change
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
end
