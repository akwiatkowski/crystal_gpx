# crystal_gpx

At this moment you can only import GPX tracks as `Array`
of points `CrystalGpx::Point`.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal_gpx:
    github: akwiatkowski/crystal_gpx
```


## Usage


```crystal
require "crystal_gpx"

path = File.join(["spec", "fixtures", "sample.gpx"])
g = CrystalGpx.load(path)
puts g.points.inspect
```


### Geotagging

Compile and install:

```bash
crystal build bin/geotag.cr --release -o bin/cr_geotag
sudo mv bin/cr_geotag /usr/bin
```

And run in directory where you store JPEG and GPX files to geotag them.

```bash
cr_geotag
```


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/akwiatkowski/crystal_gpx/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
