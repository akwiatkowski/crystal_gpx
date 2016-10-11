default:
	crystal build bin/cr_geotag.cr --release -o bin/cr_geotag

install:
	sudo mv bin/cr_geotag /usr/bin
