#!/bin/bash

#estraggo regioni
echo .
echo ESTRAZIONE REGIONI
perl estrazione_bbox.pl /mnt/scripts/csv/regioni.csv /mnt/data/pbf/italia.pbf  /mnt/estratti/regioni

sleep 300

#estraggo i comuni su base regionale
echo .
echo ESTRAZIONE COMUNI
/mnt/scripts/estrai_comuni.sh Sicilia &
/mnt/scripts/estrai_comuni.sh Lombardia &
/mnt/scripts/estrai_comuni.sh Puglia &
/mnt/scripts/estrai_comuni.sh Campania &
/mnt/scripts/estrai_comuni.sh Lazio &
/mnt/scripts/estrai_comuni.sh Molise &
/mnt/scripts/estrai_comuni.sh Umbria
/mnt/scripts/estrai_comuni.sh Toscana &
/mnt/scripts/estrai_comuni.sh Emilia &
/mnt/scripts/estrai_comuni.sh Veneto &
/mnt/scripts/estrai_comuni.sh Piemonte &
/mnt/scripts/estrai_comuni.sh Valle &
/mnt/scripts/estrai_comuni.sh Trentino &
/mnt/scripts/estrai_comuni.sh Abruzzo
/mnt/scripts/estrai_comuni.sh Marche &
/mnt/scripts/estrai_comuni.sh Basilicata &
/mnt/scripts/estrai_comuni.sh Friuli &
/mnt/scripts/estrai_comuni.sh Sardegna &
/mnt/scripts/estrai_comuni.sh Liguria &
/mnt/scripts/estrai_comuni.sh Calabria
