#!/usr/bin/perl

use strict;
use warnings;
use XML::Simple;
use I18N::Langinfo qw(langinfo CODESET);
    my $codeset = langinfo(CODESET);


my $program = "estrazione_bbox.pl" ;
my $usage = $program . " <file csv con bbox> <file pbf con dati origine> <directory di copia> " ;

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
	
	print "Estraggo $nome  \n";
my $command= "";
          $command = "/usr/local/bin/osmconvert $pbfName -t=/mnt/tmp/osmconvert_tempfile -b=$bbox  --hash-memory=1000 --complete-ways --complex-ways --out-pbf > $dirName/pbf/$nome---$rel.pbf ";
         my $null = `$command `;

         $command =  " chmod 644 $dirName/pbf/$nome---$rel.pbf ";
         $null = `$command `;

        print "converto $nome da pbf in osm\n";
        $command = "/usr/local/bin/osmconvert  -t=/mnt/tmp/osmconvert_tempfile $dirName/pbf/$nome---$rel.pbf > $dirName/osm/$nome---$rel.osm ";
        system($command);

        # prima di zippare il file devo ricavare i dati da inserire nel file README
        print "estraggo nomi utenti da file $nome \n";
        $command = "grep user  $dirName/osm/$nome---$rel.osm |  perl -nle 'print \$1 if /user=\"(.*?)\"/' | sort | uniq | tr '\n' ',' ";
        my $utenti= `$command `;

        chop($utenti); #tolgo l'ultima virgola

        my $base_url = 'http:\/\/osm-toolserver-italia.wmflabs.org\/estratti\/';
        my $filename = '';

        my $n; my $mday; my $mon; my $year;
        ($n,$n,$n,$mday,$mon,$year,$n,$n,$n) = localtime();
        $year += 1900;
        my $date_now = sprintf("%04d-%02d-%02d", $year ,$mon ,$mday);

        #copio i README

        $command = " perl -p -e 's/{{{USERS_LIST}}}/$utenti/g ;' -e 's/{{{DATE}}}/ $date_now/g ;' -e 's/{{{BASE_URL}}}{{{FILE_NAME}}}/ $base_url $filename/g'  /mnt/scripts/text/README.template.generic.txt >  $dirName/osm/README-$nome.txt";
        system($command);
        $command = " perl -p -e 's/{{{USERS_LIST}}}/$utenti/g ;' -e 's/{{{DATE}}}/ $date_now/g ;' -e 's/{{{BASE_URL}}}{{{FILE_NAME}}}/ $base_url $filename/g'  /mnt/scripts/text/LEGGIMI.template.generic.txt >  $dirName/osm/LEGGIMI-$nome.txt";
        system($command);

        print "ricavo lo shape $nome\n";
        $command = "cd $dirName/shape ; mkdir $nome ; cd $nome ; cp $dirName/osm/README-$nome.txt . ; cp  $dirName/osm/LEGGIMI-$nome.txt . ; /var/opt/osmium/osmjs/osmjs -l array -j /var/opt/osmium/osmjs/js/config.js -i /var/opt/osmium/osmjs/js/osm2shape.js $dirName/pbf/$nome---$rel.pbf 1>/dev/null && zip -m $nome---$rel.zip * 1>/dev/null ; mv *.zip .. ; cd .. ; rm -rf $nome  & ";
        system($command);

        #genero lo spatialite
        print "ricavo lo spatialite $nome\n";
        $command = "cp $dirName/osm/README-$nome.txt  $dirName/sqlite ; cp  $dirName/osm/LEGGIMI-$nome.txt  $dirName/sqlite ; rm -f $dirName/sqlite/$nome---$rel.sqlite ; ogr2ogr -f SQLite -dsco spatialite=yes  $dirName/sqlite/$nome---$rel.sqlite $dirName/osm/$nome---$rel.osm  -gt 20000  --config OGR_SQLITE_SYNCHRONOUS OFF ";
        system($command);

        #zippo file osm e spatialite
        print "zippo $nome\n";
        $command = "zip -q -j -m $dirName/osm/$nome---$rel.osm.zip $dirName/osm/$nome---$rel.osm $dirName/osm/README-$nome.txt $dirName/osm/LEGGIMI-$nome.txt 1>/dev/null ; chmod 644  $dirName/osm/$nome---$rel.osm.zip  &";
        system($command);
        $command = "zip -q -j -m $dirName/sqlite/$nome---$rel.sqlite.zip $dirName/sqlite/$nome---$rel.sqlite $dirName/sqlite/README-$nome.txt $dirName/sqlite/LEGGIMI-$nome.txt 1>/dev/null ; chmod 644  $dirName/sqlite/$nome---$rel.sqlite.zip  &";
        system($command);
        
        #estraggo il poly
        $command = "perl /mnt/scripts/getbound.pl -o $dirName/poly/$nome---$rel.poly $rel ";
        system($command);

        }

