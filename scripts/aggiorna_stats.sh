#!/bin/bash

BASEDIR='/mnt/stat_roulette'

TODAY=$(date +"%y%m%d")


cd $BASEDIR
perl show_online_tasks.pl IT_WaterCrossings > $BASEDIR/stats/IT_WaterCrossings-$TODAY.txt
perl show_online_tasks.pl IT_SelfCrossings > $BASEDIR/stats/IT_SelfCrossings-$TODAY.txt

