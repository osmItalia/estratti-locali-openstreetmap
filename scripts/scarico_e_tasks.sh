#!/bin/bash

TODAY=$(date +"%y%m%d")

echo xxxxxxxxxxxxxxx   SCARICO E TASK   xxxxxxxxxxxxxxxxxxxxx

#scarico italia e genero db
echo Scarico Italia e genero DB
/mnt/data_bin/italia_pbf2sqlite.sh > /mnt/stat_roulette/logs/log.txt

echo Lavoro sui task maproulette
cd /mnt/stat_roulette

#copio i vecchi task
#cp  tasks/IT_OpenAreas.txt  tasks/IT_OpenAreas.txt_OLD
#cp  tasks/IT_Roundabouts.txt  tasks/IT_Roundabouts.txt_OLD
cp  tasks/IT_WrongAddresses.txt  tasks/IT_WrongAddresses.txt_OLD
cp  tasks/IT_Incoherent.txt  tasks/IT_Incoherent.txt_OLD

# creo i tasks
#perl checkAreaOpenDB.pl  ../db/italia.sqlite html/openareas.html tasks/IT_OpenAreas.txt >> logs/log.txt
#perl checkRoundaboutDB.pl L ../db/italia.sqlite tasks/IT_Roundabouts.txt
perl checkWrongAddress.pl ../db/italia.sqlite tasks/IT_WrongAddresses.txt
./checkConn.sh


#apro tunnel 
./create_tunnel.sh

#se il file e' > 0 byte
#if [ -s tasks/IT_OpenAreas.txt ]
#	then
#	#faccio upload sul db
#	perl upload_json.pl tasks/IT_OpenAreas.txt IT_OpenAreas stats/IT_OpenAreas_stats-$TODAY.txt >> logs/log.txt
#fi

#se il file e' > 0 byte
#if [ -s tasks/IT_Roundabouts.txt ]
#	then
#	#faccio upload sul db
#	perl upload_json.pl tasks/IT_Roundabouts.txt IT_Roundabouts stats/IT_Roundabouts_stats-$TODAY.txt >> logs/log.txt
#fi

#se il file e' > 0 byte
if [ -s tasks/IT_WrongAddresses.txt ]
	then
	#faccio upload sul db
	perl upload_json.pl tasks/IT_WrongAddresses.txt IT_WrongAddresses stats/IT_WrongAddresses_stats-$TODAY.txt >> logs/log.txt
fi

if [ -s tasks/IT_Incoherent.txt ]
	then
	#faccio upload sul db
	perl upload_json.pl tasks/IT_Incoherent.txt IT_IncoherentHighways stats/IT_Incoherent_stats-$TODAY.txt >> logs/log.txt
fi


##################
#
# INIZIO ZONA CREAZIONE ESTRATTI 
#
#################

echo scarico_e_task - controllo esistenza di file pbf di partenza

if [ -s /mnt/data/pbf/italy-latest.osm.pbf ]
	then
	echo OK-file presente
	cd /mnt/scripts
	# creo i confini regionali/provinciali e comunali aggiornati
	echo scarico_e_task - genero bounding box
	echo ---------------------------------------------------------
	perl genera_bbox.pl 3600365331 csv

	cat csv/comuni_* > csv/comuni.csv

	#genero gli estratti
	echo scarico_e_task - genero estratti
	echo ---------------------------------------------------------
	./generazione_estratti.sh
fi
