#!/bin/sh
curl -L -o data/neighborhoods.zip https://data.milwaukee.gov/dataset/0f5695f6-bca1-46e9-832b-54d1d906d28e/resource/964353e8-a579-402a-a8e9-c50ea0ae3aa4/download/dcdneighborhoods.zip
mkdir -p data/neighborhoods
unzip -o -d data/neighborhoods data/neighborhoods.zip
cd data/neighborhoods
ogr2ogr -f GeoJSON -s_srs DCDNeighborhoods.prj -t_srs EPSG:4326 ../raw_neighborhoods.geojson DCDNeighborhoods.shp
cat ../raw_neighborhoods.geojson | jq -c '.features |= map({type: .type, properties: {name: .properties.Neighborho}, geometry: .geometry}) | .features[]' > ../neighborhood_shapefiles.jsonl

