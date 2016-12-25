require "./spec_helper"

describe CrystalGpx::Point do
  it "create Point with geo coords" do
    lat = 52.40285
    lon = 16.91062
    o = CrystalGpx::Point.new(lat, lon)

    o.lat.should eq lat
    o.lon.should eq lon
  end

  it "calculate distance Poznan-Warsaw without using Point struct" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    warsaw_lat = 52.23044
    warsaw_lon = 21.00458

    # named params
    d = CrystalGpx::Point.distance(
      lat1: poznan_lat,
      lon1: poznan_lon,
      lat2: warsaw_lat,
      lon2: warsaw_lon
    )

    d.should be > 278.70
    d.should be < 278.90

    # regular params
    d = CrystalGpx::Point.distance(
      poznan_lat,
      poznan_lon,
      warsaw_lat,
      warsaw_lon
    )

    d.should be > 278.70
    d.should be < 278.90
  end

  it "calculate distance Poznan-Warsaw with using two Point struct" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    warsaw_lat = 52.23044
    warsaw_lon = 21.00458

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)
    warsaw = CrystalGpx::Point.new(lat: warsaw_lat, lon: warsaw_lon)

    # class method
    d = CrystalGpx::Point.distance(poznan, warsaw)

    d.should be > 278.70
    d.should be < 278.90

    # instance method
    d = poznan.distance_to(warsaw)

    d.should be > 278.70
    d.should be < 278.90
  end

  it "calculate distance Poznan-Warsaw with using one Point struct" do
    poznan_lat = 52.40285
    poznan_lon = 16.91062

    warsaw_lat = 52.23044
    warsaw_lon = 21.00458

    poznan = CrystalGpx::Point.new(lat: poznan_lat, lon: poznan_lon)

    # instance method
    d = poznan.distance_to(other_lat: warsaw_lat, other_lon: warsaw_lon)

    d.should be > 278.70
    d.should be < 278.90
  end
end
