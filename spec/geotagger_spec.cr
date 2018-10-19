require "./spec_helper"

describe CrystalGpx::Geotagger do
  it "load GPX files, images and match" do
    path = File.join(["spec", "fixtures"])
    gpx_path = File.join([path, "geotag.gpx"])
    photo_path = File.join([path, "photos", "IMGP7322raw1.jpg"])

    p = CrystalGpx::Geotagger.new
    p.load_path(path)

    p.load_gpx(gpx_path)
    p.add_image(photo_path)
    p.match
  end

  it "load default config file and set camera_offset" do
    path = File.join(["spec", "fixtures", "config_test"])

    p = CrystalGpx::Geotagger.new
    p.load_path(path)

    p.camera_offset.should eq 5
    p.extrapolate.should eq true
  end

end
