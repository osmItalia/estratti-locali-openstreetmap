#!/usr/bin/perl

use strict;
use warnings;
use XML::Simple;
use Data::Dumper;


# Genero in output vari file CSV separati da | con relation id, nome e bbox di ogni entita' territoriale
# sprecificata dall'admin level
#estraggo i dati dalla relation id di partenza tramite query overpass API


my $program = "genera_bbox.pl" ;
my $usage = $program . " <id relation di partenza> <dir destinazione files>\n ID relation Italia 3600365331\n\n" ;




###############
# get parameter
###############

my $rel_id = shift||'';
if (!$rel_id)
{
        die (print $usage, "\n");
}

my $dirFile = shift||'';
if (!$dirFile)
{
        die (print $usage, "\n");
}


print "\n\nGENERO BBOX\n\n";

print "Query Overpass API per le regioni\n"; 
my $xml_data = ` curl -s -d '[out:xml][timeout:999]; area($rel_id)->.area;(relation["type"="boundary"]["boundary"="administrative"]["admin_level"="4"] (area.area););out tags geom;' http://overpass-api.de/api/interpreter`;

print "Processo dati della query\n";
my $xml = new XML::Simple;
my $data = XMLin($xml_data);


open FILE, ">:encoding(utf8)", "$dirFile/regioni.csv" or die $!;

    # Processo i dati per le regioni
my %rel_regioni  ;


foreach my $rel (keys  %{$data->{relation}}){

	my $min_lon =  $data->{relation}{$rel}->{bounds}->{minlon} ;
	my $min_lat =  $data->{relation}{$rel}->{bounds}->{minlat} ;
	my $max_lon =  $data->{relation}{$rel}->{bounds}->{maxlon} ;
	my $max_lat =  $data->{relation}{$rel}->{bounds}->{maxlat} ;

	my $nome ="";
	foreach  (keys $data->{relation}{$rel}->{tag}) {
		if ( $data->{relation}{$rel}->{tag}[$_]{k} eq "name") {
			$nome = $data->{relation}{$rel}->{tag}[$_]{v};
			}
		}
	
        $nome =~ s/ /_/g ;
        $nome =~ s/'/_/g ;
        $nome =~ s/\//_/g ;

	print FILE "$rel|$nome|$min_lon,$min_lat,$max_lon,$max_lat\n";
	$rel_regioni{$rel} = $nome;	
	}

close FILE;

print "Fine generazione file regioni\n";


#processo le province e i comuni su base regionale

foreach my $reg (keys %rel_regioni) {
	
	print "Query per province della regione $rel_regioni{$reg}\n";
	my $reg_code = $reg + 3600000000;
	my $xml_data_2 = ` curl -s -d '[out:xml][timeout:999]; area($reg_code)->.area;(relation["type"="boundary"]["boundary"="administrative"]["admin_level"="6"] (area.area););out tags geom;' http://overpass-api.de/api/interpreter`;
	print "   Processo dati della query (relation_code = $reg_code)\n";
	my $xml2 = new XML::Simple;
	my $data2 = XMLin($xml_data_2, ForceArray => 1);

	print "   Scrivo file\n";
	open FILE,  ">:encoding(utf8)","$dirFile/province_$rel_regioni{$reg}.csv" or die $!;
	my $size = keys  %{$data2->{relation}};

	if ($size >0) {	
		foreach my $rel (keys  %{$data2->{relation}}){

			my $min_lon =  $data2->{relation}{$rel}->{bounds}[0]->{minlon} ;
			my $min_lat =  $data2->{relation}{$rel}->{bounds}[0]->{minlat} ;
			my $max_lon =  $data2->{relation}{$rel}->{bounds}[0]->{maxlon} ;
			my $max_lat =  $data2->{relation}{$rel}->{bounds}[0]->{maxlat} ;

			my $nome ="";
			foreach  (keys $data2->{relation}{$rel}->{tag}) {
				if ( $data2->{relation}{$rel}->{tag}[$_]{k} eq "name") {
					$nome = $data2->{relation}{$rel}->{tag}[$_]{v};
					}
				}
	
      			$nome =~ s/ /_/g ;
        		$nome =~ s/'/_/g ;
        		$nome =~ s/\//_/g ;

			print FILE "$rel|$nome|$min_lon,$min_lat,$max_lon,$max_lat\n";
    			}	
		close FILE;
		}

########### COMUNI ##########


	print "Query per comuni della regione $rel_regioni{$reg}\n";

	my $xml_data_3 = ` curl -s -d '[out:xml][timeout:999]; area($reg_code)->.area;(relation["type"="boundary"]["boundary"="administrative"]["admin_level"="8"] (area.area););out tags geom;' http://overpass-api.de/api/interpreter`;
	print "   Processo dati della query (relation_code = $reg_code)\n";
	my $xml3 = new XML::Simple;
	my $data3 = XMLin($xml_data_3);

	print "   Scrivo file\n";
	open FILE, ">:encoding(utf8)", "$dirFile/comuni_$rel_regioni{$reg}.csv" or die $!;
	$size = keys  %{$data3->{relation}};

	if ($size >0) {	
		foreach my $rel (keys  %{$data3->{relation}}){

			my $min_lon =  $data3->{relation}{$rel}->{bounds}->{minlon} ;
			my $min_lat =  $data3->{relation}{$rel}->{bounds}->{minlat} ;
			my $max_lon =  $data3->{relation}{$rel}->{bounds}->{maxlon} ;
			my $max_lat =  $data3->{relation}{$rel}->{bounds}->{maxlat} ;

			my $nome ="";
			foreach  (keys $data3->{relation}{$rel}->{tag}) {
				if ( $data3->{relation}{$rel}->{tag}[$_]{k} eq "name") {
					$nome = $data3->{relation}{$rel}->{tag}[$_]{v};
					}
				}
	
      			$nome =~ s/ /_/g ;
        		$nome =~ s/'/_/g ;
        		$nome =~ s/\//_/g ;

			print FILE "$rel|$nome|$min_lon,$min_lat,$max_lon,$max_lat\n";
    			}	
		close FILE;

		}	
	}
