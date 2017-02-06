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
    direction.should eq 180.0
  end

  it "calculate direction Poznan and something to the north" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 54.49915
    point_lon = 16.91062

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq 0.0
  end

  it "calculate direction Poznan and something to the east" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 52.40285
    point_lon = 20.96811

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq 90.0
  end

  it "calculate direction Poznan and something to the west" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    point_lat = 52.40285
    point_lon = 14.20878

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    point = CrystalGpx::Point.new(lat: point_lat, lon: point_lon)

    direction = poznan.direction_to(point)
    direction.should eq 270.0
  end

  it "short human direction" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062
    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)

    [
      {lat: 1.0, lon: 0.0, human: "N"},    # N1.0
      {lat: 1.0, lon: 1.0, human: "NE"},   # N1.0 E1.0
      {lat: 0.0, lon: 1.0, human: "E"},    # E1.0
      {lat: -1.0, lon: 1.0, human: "SE"},  # S1.0 E1.0
      {lat: -1.0, lon: 0.0, human: "S"},   # S1.0
      {lat: -1.0, lon: -1.0, human: "SW"}, # S1.0 W1.0
      {lat: 0.0, lon: -1.0, human: "W"},   # W1.0
      {lat: 1.0, lon: -1.0, human: "NW"},  # N1.0 W1.0
    ].each do |t|
      # between (-180,90> result = 90 - D
      point = CrystalGpx::Point.new(lat: poznan_lat + t[:lat], lon: poznan_lon + t[:lon])
      direction = poznan.direction_to(point)
      human_direction = CrystalGpx::Point.direction_to_human(direction)

      human_direction.should eq t[:human]
    end
  end
end
