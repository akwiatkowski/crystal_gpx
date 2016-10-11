require "./spec_helper"

describe CrystalGpx::Parser do
  it "interpolate points" do
    point_a = CrystalGpx::Point.new
    point_a.lat = 10.0
    point_a.lon = 10.0
    point_a.ele = 100.0
    point_a.time = Time.epoch(1_000_000)

    point_b = CrystalGpx::Point.new
    point_b.lat = 20.0
    point_b.lon = 20.0
    point_b.ele = 200.0
    point_b.time = Time.epoch(2_000_000)

    time = Time.epoch(1_500_000)

    result = CrystalGpx::Point.interpolate(
      points: [point_a, point_b],
      time: time
    )

    result.should be_a CrystalGpx::Point
    result.not_nil!.lat.should eq 15.0
    result.not_nil!.lon.should eq 15.0
    result.not_nil!.ele.should eq 150.0
    result.not_nil!.time.epoch.should eq 1_500_000
  end
end
