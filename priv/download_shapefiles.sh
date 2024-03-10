#!/bin/sh
wget https://data.milwaukee.gov/dataset/3e238aee-5a21-4e2f-8ae7-803440c5d88a/resource/39a759e9-c5fb-4f58-98be-493fa2bf8ab5/download/parcelpolygontax2023.zip -O data/shapefiles.zip
cd data/
mkdir shapefiles
unzip -o -d shapefiles shapefiles.zip
cd shapefiles
ogr2ogr -f GeoJSON -s_srs ParcelPolygonTax.prj -t_srs EPSG:4326 ../assessment_shapefiles.geojson ParcelPolygonTax.shp
