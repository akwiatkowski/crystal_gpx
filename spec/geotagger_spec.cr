require "./spec_helper"

describe CrystalGpx::Parser do
  it "load GPX file" do
    path = File.join(["spec", "fixtures", "sample.gpx"])
    p = CrystalGpx::Geotagger.new
    p.load_gpx(path)
  end
end
