require "./spec_helper"

describe CrystalGpx::Point do
  it "calculate direction Poznan and something to the south" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 52.03390
    point_lon = 16.91062

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq -90.0
  end

  it "calculate direction Poznan and something to the north" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 54.49915
    point_lon = 16.91062

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq 90.0
  end

  it "calculate direction Poznan and something to the east" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 52.40285
    point_lon = 20.96811

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq 0.0
  end

  it "calculate direction Poznan and something to the west" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 52.40285
    point_lon = 14.20878

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq 180.0
  end

end
