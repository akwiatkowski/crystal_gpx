require "log"

class CrystalGpx::PrivateMode
  Log = ::Log.for(self)

  def initialize(
    @array : Array(CrystalGpx::Point),
    @range : Int32,
    @spot : CrystalGpx::Point,
  )
    @result = @array.dup
  end

  def make_it_so
    trim_start
    trim_finish

    return @result
  end

  def trim_start
    while @result.size > 0
      distance = @result.first.distance_to(@spot)
      if (distance * 1000.0).to_i > @range
        Log.info { "#{self.class}: start is ok now" }
        return
      else
        Log.info { "#{self.class}: start removed #{distance}" }
        @result.shift
      end
    end
  end

  def trim_finish
    while @result.size > 0
      distance = @result.last.distance_to(@spot)
      if (distance * 1000.0).to_i > @range
        Log.info { "#{self.class}: finish is ok now" }
        return
      else
        Log.info { "#{self.class}: finish removed #{distance}" }
        @result.pop
      end
    end
  end
end
