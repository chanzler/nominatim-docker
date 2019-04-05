# Nominatim Docker
Dockerfile for nominatim geocoding service (openstreetmaps). Uses nominatim 3.2 and postgres 10.

1. Build

    docker build -t nominatim .

2. Initialize Nominatim Database

Please note that initialization may take a while, depending on the amount of data you want to import.

    docker run -d -v data:/var/lib/postgresql/10/main -e NOMINATIM_MODE=CREATE --name nominatim-create nominatim

If you want to see whats going on in your docker container use

    docker logs -f nominatim-create

If you want to import a different country than germany, you can specify the download URL of the osm.pbf file as follows:

    docker run -d -v data:/var/lib/postgresql/10/main -e NOMINATIM_PBF_URL=http://download.geofabrik.de/asia/maldives-latest.osm.pbf -e NOMINATIM_MODE=CREATE --name nominatim-create  nominatim

3. Run 

    docker run -d -p 8080:8080 -v data:/var/lib/postgresql/10/main --restart=always --name nominatim nominatim
