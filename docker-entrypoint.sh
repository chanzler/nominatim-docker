#!/bin/bash

#if [ "$NOMINATIM_MODE" != "CREATE" ] && [ "$NOMINATIM_MODE" != "RESTORE" ]; then
#    # Default to CREATE
#    NOMINATIM_MODE="CREATE"
#fi

# Defaults
NOMINATIM_DATA_PATH=${NOMINATIM_DATA_PATH:="/srv/nominatim/data"}
NOMINATIM_DATA_LABEL=${NOMINATIM_DATA_LABEL:="data"}
NOMINATIM_PBF_URL=${NOMINATIM_PBF_URL:="http://download.geofabrik.de/europe/germany-latest.osm.pbf"}
NOMINATIM_POSTGRESQL_DATA_PATH=${NOMINATIM_POSTGRESQL_DATA_PATH:="/var/lib/postgresql/10/main"}

if [ "$NOMINATIM_MODE" == "CREATE" ]; then
    
    # Retrieve the PBF file
    curl -L $NOMINATIM_PBF_URL --create-dirs -o $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf
    # Allow user accounts read access to the data
    chmod 755 $NOMINATIM_DATA_PATH
    sudo -u postgres psql -c "create extension postgis"
    sudo chown -R postgres:postgres $NOMINATIM_POSTGRESQL_DATA_PATH

    # Start PostgreSQL
    service postgresql start

    # Import data
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
    sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
    useradd -m -p password1234 nominatim
    echo "Importing $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf"
    sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf --all --threads 2 2>&1 | tee setup.log

else 
    # Start PostgreSQL
    service postgresql start
    
    # Tail Apache logs
    tail -f /var/log/apache2/* &

    # Run Apache in the foreground
    /usr/sbin/apache2ctl -D FOREGROUND

fi
