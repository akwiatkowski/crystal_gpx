require "./spec_helper"

describe CrystalGpx::Parser do
  it "load GPX file" do
    path = File.join(["spec", "fixtures"])
    gpx_path = File.join([path, "geotag.gpx"])
    photo_path = File.join([path, "photos", "IMGP7322raw1.jpg"])

    p = CrystalGpx::Geotagger.new
    p.load_path(path)

    # p.load_gpx(gpx_path)
    # p.add_image(photo_path)
    # p.match
  end
end
