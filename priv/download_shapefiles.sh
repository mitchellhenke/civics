#!/bin/sh
curl -L -o data/shapefiles.zip https://data.milwaukee.gov/dataset/3e238aee-5a21-4e2f-8ae7-803440c5d88a/resource/a8880aaa-19b6-4d7b-90ce-6282688e8e98/download/parcelpolygontax2025.zip
mkdir -p data/shapefiles
unzip -o -d data/shapefiles data/shapefiles.zip
cd data/shapefiles
ogr2ogr -f GeoJSON -s_srs ParcelPolygonTax.prj -t_srs EPSG:4326 ../raw_assessment_shapefiles.geojson ParcelPolygonTax.shp

cat ../raw_assessment_shapefiles.geojson | jq -c '.features |= map({type: .type, properties: {Taxkey: .properties.Taxkey}, geometry: .geometry}) | .features[]' > ../assessment_shapefiles.jsonl
