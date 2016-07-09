require "./spec_helper"

describe CrystalGpx do
  it "load GPX file" do
    path = File.join(["spec", "fixtures", "sample.gpx"])
    g = CrystalGpx.load(path)
    g.points.size.should eq 2
  end
end
