#!/bin/bash

BASEDIR='/mnt/stat_roulette'

TODAY=$(date +"%y%m%d")

export TMPDIR=/mnt/tmp

cd $BASEDIR
osmosis --read-pbf-fast workers=3 file=/mnt/data/pbf/italy-latest.osm.pbf --wx /dev/stdout | perl -nle 'print $1 if /user="(.*?)"/' | sort | uniq -c | sort -n -r > $BASEDIR/stats/utenti_unici_italia-$TODAY.txt

