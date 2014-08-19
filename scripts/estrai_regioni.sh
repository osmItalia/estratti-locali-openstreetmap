#!/bin/bash

PBF=`ls /mnt/data/pbf/italia*`
CSV=`ls /mnt/scripts/csv/regioni*`

perl  estrazione_bbox.pl $CSV  $PBF /mnt/estratti/regioni

