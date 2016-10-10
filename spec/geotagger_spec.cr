require "./spec_helper"

describe CrystalGpx::Parser do
  it "load GPX file" do
    gpx_path = File.join(["spec", "fixtures", "geotag.gpx"])
    photo_path = File.join(["spec", "fixtures", "photos", "IMGP7322raw1.jpg"])

    p = CrystalGpx::Geotagger.new
    p.load_gpx(gpx_path)
    p.add_image(photo_path)
    p.match
  end
end
