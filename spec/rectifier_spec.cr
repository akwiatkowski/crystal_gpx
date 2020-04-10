require "./spec_helper"

describe CrystalGpx::Rectifier do
  it "process existing coords to much smaller" do
    path = File.join(["spec", "fixtures", "big", "2019-08-07_072513.gpx"])
    cg = CrystalGpx.load(path)

    # start processing
    rectifier = CrystalGpx::Rectifier.new(cg.points)
    result = rectifier.make_it_so.not_nil!

    result.size.should be < cg.points.size
  end
end
