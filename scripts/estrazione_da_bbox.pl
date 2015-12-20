#!/usr/bin/perl

use strict;
use warnings;
use XML::Simple;
use I18N::Langinfo qw(langinfo CODESET);
    my $codeset = langinfo(CODESET);


my $program = "estrazione_bbox.pl" ;
my $usage = $program . " <file csv con bbox> <file pbf con dati origine> <directory di copia> " ;

my $BASEDIR_SH='/srv/estratti/scripts';

# necessario per gestire i file con caratteri UTF-8
use Encode qw(decode);
    @ARGV = map { decode $codeset, $_ } @ARGV;


###############
# get parameter
###############

my $bboxName = shift||'';
if (!$bboxName)
{
        die (print $usage, "\n");
}

my $pbfName = shift||'';
if (!$pbfName)
{
        die (print $usage, "\n");
}

my $dirName = shift||'';
if (!$dirName)
{
        die (print $usage, "\n");
}

my $rel;
my $nome;
my $bbox;


open(my $fh, '<:encoding(UTF-8)', $bboxName)
or die "Could not open file '$bboxName' $!";

while (my $row = <$fh>) {
        chomp $row;
        my @p = split('\|',$row);
        $rel = $p[0];
        $nome = $p[1];
        $bbox = $p[2];

	#normalizzazione del $nome
	#rimozione ' spazi / \

	$nome =~ s/ /_/g;
	$nome =~ s/\//_/g;
	$nome =~ s/\\/_/g;
	$nome =~ s/'/_/g;

        print "Estraggo $nome\n";

	my $command= "";

          $command = "/usr/local/bin/osmconvert $pbfName -t=/srv/tmp/osmconvert_tempfile -b=$bbox  --hash-memory=1000  --drop-broken-refs --out-pbf > $dirName/pbf/$rel---$nome.pbf ";
         my $null = `$command `;

         $command =  " chmod 644 $dirName/pbf/$rel---$nome.pbf ";
         $null = `$command `;

        print "converto $nome da pbf in osm\n";
        $command = "/usr/local/bin/osmconvert  -t=/srv/tmp/osmconvert_tempfile $dirName/pbf/$rel---$nome.pbf > $dirName/osm/$rel---$nome.osm ";
        system($command);


        # prima di zippare il file devo ricavare i dati da inserire nel file README
        print "estraggo nomi utenti da file $nome \n";

        #$command = "grep user  $dirName/osm/$rel---$nome.osm |  perl -nle 'print \$1 if /user=\"(.*?)\"/' | sort | uniq | tr '\n' ',' ";
	$command = "grep user  $dirName/osm/$rel---$nome.osm |  perl -nle 'print \$1 if /user=\"(.*?)\"/' | sort | uniq | sed  ':a;N;\$!ba;s|\\n|, |g' | fold -s -w 80 ";

        my $utenti= `$command `;

        chop($utenti); #tolgo l'ultima virgola

        my $base_url = 'http:\/\/osm-toolserver-italia.wmflabs.org\/estratti\/';
        my $filename = '';

        my $n; my $mday; my $mon; my $year;
        ($n,$n,$n,$mday,$mon,$year,$n,$n,$n) = localtime();
        $year += 1900;
        $mon += 1;
        my $date_now = sprintf("%04d-%02d-%02d", $year ,$mon ,$mday);

        #copio i README

        $command = " perl -p -e 's/{{{USERS_LIST}}}/$utenti/g ;' -e 's/{{{DATE}}}/ $date_now/g ;' -e 's/{{{BASE_URL}}}{{{FILE_NAME}}}/ $base_url $filename/g'  $BASEDIR_SH/text/README.template.generic.txt >  $dirName/osm/README-$nome.txt";
        system($command);
        $command = " perl -p -e 's/{{{USERS_LIST}}}/$utenti/g ;' -e 's/{{{DATE}}}/ $date_now/g ;' -e 's/{{{BASE_URL}}}{{{FILE_NAME}}}/ $base_url $filename/g'  $BASEDIR_SH/text/LEGGIMI.template.generic.txt >  $dirName/osm/LEGGIMI-$nome.txt";
        system($command);

	#genero gli shapefile
        print "ricavo lo shape $nome\n";
        $command = "cd $dirName/shape ; mkdir $nome ; cd $nome ; cp $dirName/osm/README-$nome.txt . ; cp  $dirName/osm/LEGGIMI-$nome.txt . ; /var/opt/osmium/osmjs/osmjs -l array -j /var/opt/osmium/osmjs/js/config.js -i /var/opt/osmium/osmjs/js/osm2shape.js $dirName/pbf/$rel---$nome.pbf 1>/dev/null && zip -m $rel---$nome.zip * 1>/dev/null ; mv *.zip .. ; cd .. ; rm -rf $nome  & ";
        system($command);

        #genero lo spatialite
        print "ricavo lo spatialite $nome\n";
        $command = "cp $dirName/osm/README-$nome.txt  $dirName/sqlite ; cp  $dirName/osm/LEGGIMI-$nome.txt  $dirName/sqlite ; rm -f $dirName/sqlite/$nome---$rel.sqlite ; ogr2ogr -f SQLite -dsco spatialite=yes  $dirName/sqlite/$rel---$nome.sqlite $dirName/osm/$rel---$nome.osm  -gt 20000  --config OGR_SQLITE_SYNCHRONOUS OFF ";
        system($command);

        #zippo file osm e spatialite
        $command = "rm -f $dirName/osm/$rel---$nome.osm.zip; rm -f $dirName/sqlite/$rel---$nome.sqlite.zip";
        system($command);

        print "zippo $nome\n";
        $command = "zip -q -j -m $dirName/osm/$rel---$nome.osm.zip $dirName/osm/$rel---$nome.osm $dirName/osm/README-$nome.txt $dirName/osm/LEGGIMI-$nome.txt 1>/dev/null ; chmod 644  $dirName/osm/$rel---$nome.osm.zip  &";
        system($command);
        $command = "zip -q -j -m $dirName/sqlite/$rel---$nome.sqlite.zip $dirName/sqlite/$rel---$nome.sqlite $dirName/sqlite/README-$nome.txt $dirName/sqlite/LEGGIMI-$nome.txt 1>/dev/null ; chmod 644  $dirName/sqlite/$rel---$nome.sqlite.zip  &";
        system($command);


        #estraggo il poly
	print "estraggo il poly per $nome\n";

	# se il codice ISTAT e' di 2 cifre allora e' una regione
        # di 3 cifre e' provincia
        # di 6 cifre e' comune
	if (length($rel) == 2) {      
		$command = "psql -h localhost -U osm -d osm -tq -c \"select st_astext(geom) from it_regioni where cod_istat='$rel'\" | python $BASEDIR_SH/get_poly.py >  $dirName/poly/$rel---$nome.poly" ;
        	system($command);
		}

	if (length($rel) == 3) {      
		$command = "psql -h localhost -U osm -d osm -tq -c \"select st_astext(geom) from it_province where cod_istat='$rel'\" | python $BASEDIR_SH/get_poly.py >  $dirName/poly/$rel---$nome.poly" ;
        	system($command);
		}

	if (length($rel) == 6) {      
		$command = "psql -h localhost -U osm -d osm -tq -c \"select st_astext(geom) from it_comuni where cod_istat='$rel'\" | python $BASEDIR_SH/get_poly.py >  $dirName/poly/$rel---$nome.poly" ;
        	system($command);
		}

        }


