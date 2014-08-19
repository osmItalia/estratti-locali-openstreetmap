#!/usr/bin/perl




use strict ;
use warnings ;

use POSIX;


my $program = "estrazione_html.pl" ;
my $usage = $program . " <db spatialite confini> <tipo output R=regioni P=province C=comuni> <dir di output>" ;


my $query;

###############
# get parameter
###############

my $dbName = shift||'';
if (!$dbName)
{
        die (print $usage, "\n");
}

my $tipo = shift||'';
if (!$tipo)
{
        die (print $usage, "\n");
}

my $dirHtml = shift||'';
if (!$dirHtml)
{
        die (print $usage, "\n");
}





sub size_in_mb {
    my $size_in_bytes = shift;
    return floor($size_in_bytes / (1024 * 1024));
}


if($tipo eq 'R') {
	open (HTML, ">$dirHtml/regioni.html");
	}
if($tipo eq 'P') {
	open (HTML, ">$dirHtml/province.html");
	}
if($tipo eq 'C') {
	open (HTML, ">$dirHtml/comuni.html");
	}

print HTML "<html>\n";
print HTML "<head>\n";
print HTML "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n";
print HTML  "</head><body>\n";

if($tipo eq 'R') {
	print HTML  "<h1>Estratti regionali</h1>\n";
	print HTML "<table border=1>\n";
	print HTML "<tr><th>Regione</th><th>Bounding Box</th><th>File PBF (dimensione)</th><th>File osm.bz2 (dimensione)</th></tr>\n";

	$query = "select rel_id, name, min_x, min_y, max_x, max_y from info_regioni order by name"; 
	}

if($tipo eq 'P') {
	print HTML "<h1>Estratti Provinciali</h1>\n";
	print HTML "<table border=1>\n";
	print HTML "<tr><th>Provincia</th><th>Bounding Box</th><th>File PBF (dimensione)</th><th>File osm.bz2 (dimensione)</th></tr>\n";

	$query = "select rel_id, name, min_x, min_y, max_x, max_y from info_province order by name"; 
	}




if ($tipo eq 'R' || $tipo eq 'P') {
	my $risultati = `spatialite $dbName  "$query" `;

	while($risultati =~ /([^\n]+)\n?/g){
		my @values = split('\|', $1);

		my $rel = $values[0];
		my $nome = $values[1];
		my $nome_orig = $nome;
		my $min_lon =   $values[2] ;
		my $min_lat =   $values[3] ;
		my $max_lon =   $values[4] ;
		my $max_lat =   $values[5] ;



		$nome =~ s/ /_/g ;
		$nome =~ s/'/_/g ;
		$nome =~ s/\//_/g ;

		if ($tipo eq 'R') {
			print HTML "<tr><td>$nome_orig (<a href=\"http://osm.org/relation/$rel\">osm</a>)</td><td>$min_lon,$min_lat,$max_lon,$max_lat</td><td><a href=\"/estratti/regioni/pbf/$rel-$nome.pbf\">$rel-$nome.pbf</a> (". size_in_mb( -s "/mnt/estratti/regioni/pbf/$rel-$nome.pbf") ." MB)</td><td><a href=\"/estratti/regioni/osm/$rel-$nome.osm.bz2\">$rel-$nome.osm.bz2</a> (". size_in_mb( -s "/mnt/estratti/regioni/osm/$rel-$nome.osm.bz2") ." MB)</td></tr>\n";
			}
		if ($tipo eq 'P') {
			print HTML "<tr><td>$nome_orig (<a href=\"http://osm.org/relation/$rel\">osm</a>)</td><td>$min_lon,$min_lat,$max_lon,$max_lat</td><td><a href=\"/estratti/province/pbf/$rel-$nome.pbf\">$rel-$nome.pbf</a> (". size_in_mb( -s "/mnt/estratti/province/pbf/$rel-$nome.pbf") ." MB)</td><td><a href=\"/estratti/province/osm/$rel-$nome.osm.bz2\">$rel-$nome.osm.bz2</a> (". size_in_mb( -s "/mnt/estratti/province/osm/$rel-$nome.osm.bz2") ." MB)</td></tr>\n";
			}
		}

	print HTML "</table>\n";
	}



if($tipo eq 'C') {
	#suddivido i comuni per regione e provincia
	print HTML "<h1>Estratti Comunali</h1>\n";
	print HTML "<p>Seleziona la regione:</p>\n";
	$query = "select  c.name,p.name,p.nome_regione from info_province as p,info_comuni as c where p.rel_id=c.id_provincia"; 
	my $risultati = `spatialite $dbName  "$query" `;

	my %hash;

	while($risultati =~ /([^\n]+)\n?/g){
		my @values = split('\|', $1);

		my $nome_comune = $values[0];
		my $nome_prov = $values[1];
		my $nome_reg = $values[2];
	
		$hash{$nome_reg}{$nome_prov} = $nome_comune;		
    }		
		}
	}
print HTML "</body></html>\n";




