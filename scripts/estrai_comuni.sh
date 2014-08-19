#!/bin/bash


PBF=`ls /mnt/estratti/regioni/pbf/$1* ` 
CSV=`ls /mnt/scripts/csv/comuni_$1*  `


perl estrazione_bbox.pl $CSV  $PBF /mnt/estratti/comuni

