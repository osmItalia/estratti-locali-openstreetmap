#!/bin/bash

BASEDIR_IT='/srv/downloads'
BASEDIR_DB='/srv/db'
BASEDIR_SH='/srv/estratti/scripts'
BASEDIR_WW='/srv/estratti/html'


R='italia'

# scaricare il file osm.pbf

echo +++ wget file italy
cd $BASEDIR_IT
wget -q -N http://download.geofabrik.de/europe/italy-latest.osm.pbf

# scaricare md5 del file

wget -q -N http://download.geofabrik.de/europe/italy-latest.osm.pbf.md5

#scaricare la data e ora dell'ìultimo aggiornamento

wget -q -N http://download.geofabrik.de/europe/italy-updates/state.txt
echo +++ fine wget


if [[ -f $BASEDIR_IT/italy-latest.osm.pbf.md5 && -f $BASEDIR_IT/italy-latest.osm.pbf ]];
        then
                echo OK-file PBF e MD5 presenti
                #check md5 del file per proseguire
                md5sum --status -c italy-latest.osm.pbf.md5
                if [ $? -ne 0 ]
                        then
                                echo checksum file PBF fallito.  EXIT
                                exit
                        else
                                echo md5sum ok
                fi

        else
                echo ERRORE-file non presente
                exit
        fi

####### inizio elaborazione
echo ---------------- inizio



cd $BASEDIR_SH

## caricare i confini nel DB tramite osm2pgsql

/usr/local/bin/osm2pgsql --create --slim --drop --latlong --number-processes 6 -H 127.0.0.1 -U osm -d osm -p italy_osm $BASEDIR_IT/italy-latest.osm.pbf

#inizializzare DB 
psql -h localhost -U osm -d osm -f $BASEDIR_SH/db_query/2_insert_update_com_pro_reg.sql


## estrarre dal db i file CSV regionali
# togliendo il primo carattere alle righe che e' uno spazio
echo "Estrazione CSV regioni"

psql -h localhost -U osm -d osm -tq -f $BASEDIR_SH/db_query/4_estrazione_csv_regioni.sql | sed 's/^.//' > $BASEDIR_SH/csv/regioni.csv
#tolgo l'ultima riga dal file perche' e' vuota
sed -i '$ d' $BASEDIR_SH/csv/regioni.csv


## estraggo dal DB i file dei comuni suddivisi per regione
# utilizzo il codice_istat_reg che va da 01 a 20

for REG in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 
do
	echo "estraggo CSV regione $REG"
	psql -h localhost -U osm -d osm -tq -c "select cod_istat || '|' || safe_name || '|' ||  bbox from it_comuni where cod_istat_reg='$REG'" \
	  | sed 's/^.//' > $BASEDIR_SH/csv/$REG-comuni.csv
	#tolgo l'ultima riga dal file perche' e' vuota
	sed -i '$ d' $BASEDIR_SH/csv/$REG-comuni.csv
done


#################################################################################


#estraggo regioni
echo .
echo ESTRAZIONE REGIONI
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/regioni.csv $BASEDIR_IT/italy-latest.osm.pbf  $BASEDIR_WW/regioni

#attendo che lo script precedente finisca
sleep 300

#estraggo i comuni su base regionale
echo .
echo ESTRAZIONE COMUNI


#Sicilia
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/19-comuni.csv $BASEDIR_WW/regioni/pbf/19*  $BASEDIR_WW/comuni &

#Lombardia
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/03-comuni.csv $BASEDIR_WW/regioni/pbf/03*  $BASEDIR_WW/comuni &

#Puglia
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/16-comuni.csv $BASEDIR_WW/regioni/pbf/16*  $BASEDIR_WW/comuni &

#Campania
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/15-comuni.csv $BASEDIR_WW/regioni/pbf/15*  $BASEDIR_WW/comuni &

#Lazio
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/12-comuni.csv $BASEDIR_WW/regioni/pbf/12*  $BASEDIR_WW/comuni 

#Fine primo blocco


#Molise
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/14-comuni.csv $BASEDIR_WW/regioni/pbf/14*  $BASEDIR_WW/comuni &

#Umbria
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/10-comuni.csv $BASEDIR_WW/regioni/pbf/10*  $BASEDIR_WW/comuni & 

#Toscana
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/09-comuni.csv $BASEDIR_WW/regioni/pbf/09*  $BASEDIR_WW/comuni &

#Emilia
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/08-comuni.csv $BASEDIR_WW/regioni/pbf/08*  $BASEDIR_WW/comuni

#Fine secondo blocco


#Veneto
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/05-comuni.csv $BASEDIR_WW/regioni/pbf/05*  $BASEDIR_WW/comuni &

#Piemonte
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/01-comuni.csv $BASEDIR_WW/regioni/pbf/01*  $BASEDIR_WW/comuni &

#Valle d'Aosta
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/02-comuni.csv $BASEDIR_WW/regioni/pbf/02*  $BASEDIR_WW/comuni &

#Trentino AA
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/04-comuni.csv $BASEDIR_WW/regioni/pbf/04*  $BASEDIR_WW/comuni 

#Fine terzo blocco


#Marche
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/11-comuni.csv $BASEDIR_WW/regioni/pbf/11*  $BASEDIR_WW/comuni &

#Basilicata
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/17-comuni.csv $BASEDIR_WW/regioni/pbf/17*  $BASEDIR_WW/comuni &

#Friuli
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/06-comuni.csv $BASEDIR_WW/regioni/pbf/06*  $BASEDIR_WW/comuni &

#Sardegna
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/20-comuni.csv $BASEDIR_WW/regioni/pbf/20*  $BASEDIR_WW/comuni 

#Fine quarto blocco


#Liguria
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/07-comuni.csv $BASEDIR_WW/regioni/pbf/07*  $BASEDIR_WW/comuni &

#Calabria
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/18-comuni.csv $BASEDIR_WW/regioni/pbf/18*  $BASEDIR_WW/comuni &

#Abruzzo
perl  $BASEDIR_SH/estrazione_da_bbox.pl $BASEDIR_SH/csv/13-comuni.csv $BASEDIR_WW/regioni/pbf/13*  $BASEDIR_WW/comuni 

echo FINITO
date
echo .
