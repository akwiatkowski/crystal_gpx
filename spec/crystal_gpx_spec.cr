require "./spec_helper"

describe CrystalGpx do
  it "load GPX file" do
    path = File.join(["spec", "fixtures", "sample.gpx"])
    g = CrystalGpx.load(path)
    points = g.points

    points.size.should eq 2

    points[0].time.year.should eq 2015
    points[0].time.month.should eq 4
    points[0].time.day.should eq 17
    points[0].lat.should eq 52.4931185134
    points[0].lon.should eq 16.9433531631
    points[0].ele.should eq 90.50

    points[1].time.year.should eq 2015
    points[1].time.month.should eq 4
    points[1].time.day.should eq 17
    points[1].lat.should eq 52.4935152289
    points[1].lon.should eq 16.9437295943
  end
end
