#!/bin/bash

BASEDIR_SH='/srv/estratti/scripts'


cd $BASEDIR_SH

date

# statistiche computate in background perche' ci impiegano tanto
psql -h localhost -U osm -d osm -f $BASEDIR_SH/db_query/3_statistiche_per_com_reg.sql

echo FINITO stats
date
echo .
