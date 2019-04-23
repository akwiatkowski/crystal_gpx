require "./spec_helper"

location = Time::Location.load("Europe/Berlin")

describe CrystalGpx::Point do
  it "interpolate points" do
    time_zero = Time::UNIX_EPOCH + Time::Span.new(seconds: 1_000_000, nanoseconds: 0)
    time_full = Time::UNIX_EPOCH + Time::Span.new(seconds: 2_000_000, nanoseconds: 0)
    time_half = Time::UNIX_EPOCH + Time::Span.new(seconds: 1_500_000, nanoseconds: 0)

    point_a = CrystalGpx::Point.new
    point_a.lat = 10.0
    point_a.lon = 10.0
    point_a.ele = 100.0
    point_a.time = time_zero

    point_b = CrystalGpx::Point.new
    point_b.lat = 20.0
    point_b.lon = 20.0
    point_b.ele = 200.0
    point_b.time = time_full

    result = CrystalGpx::Point.interpolate(
      points: [point_a, point_b],
      time: time_half
    )

    result.should be_a CrystalGpx::Point
    result.not_nil!.lat.should eq 15.0
    result.not_nil!.lon.should eq 15.0
    result.not_nil!.ele.should eq 150.0
    result.not_nil!.time.should eq time_half
  end
end
