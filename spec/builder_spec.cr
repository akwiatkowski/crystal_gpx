require "./spec_helper"

describe CrystalGpx::Rectifier do
  it "loads 2 gpx and merge into one" do
    names = [
      "2019-08-07_072513.gpx",
      "2019-08-08_172540.gpx",
    ]
    out_path = "tmp.gpx"

    points_sets = names.map do |name|
      path = File.join(["spec", "fixtures", "big", name])
      cg = CrystalGpx.load(path)
      points = cg.points

      # lets use rectifier also
      rectifier = CrystalGpx::Rectifier.new(points)
      points = rectifier.make_it_so.not_nil!

      points
    end

    builder = CrystalGpx::Builder.new(points_sets)

    File.open(out_path, "w") do |f|
      f << builder.to_gpx
    end
  end
end
