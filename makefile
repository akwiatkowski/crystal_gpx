default:
	crystal build bin/cr_geotag.cr --release -o bin/cr_geotag
	crystal build bin/gpx_rectifier.cr --release -o bin/gpx_rectifier

linux_install:
	sudo mv bin/cr_geotag /usr/bin
	sudo mv bin/gpx_rectifier /usr/bin

mac_install:
	mv bin/cr_geotag ~/Apps
	mv bin/gpx_rectifier ~/Apps
