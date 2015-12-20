<html>
 <head>
<meta charset="UTF-8">
</head>
<body>
<pre>

<?php

// array che contiene le statistiche
$conn = pg_connect("host=localhost port=5432 dbname=osm user=osm")
or die("Could not connect");

$result = pg_query($conn, "select c.name, s.k, s.v from it_comuni c, it_stats s where c.osm_id=s.osm_id order by c.name, s.k");
if (!$result) {
    echo "An error occurred.\n";
    exit;
}

while ($row = pg_fetch_row($result)) {
	$stats[$row[0]][$row[1]] =  $row[2];
}
?>

<table border=1>
<tr><th>Comune</th><th>Num. edifici</th><th>Num. civici</th><th>Num. segmenti strade</th><th>Lunghezza strade (metri)</th><th>Numero segmenti strade con nome</th><th>Lunghezza strade con nome (metri)</th></tr>


<?php
foreach ($stats as $key => $value) {
	echo "<tr><td>$key</td>";
	echo "<td>". $stats[$key]['buildings'] . "</td>\n";
	echo "<td>". $stats[$key]['civici'] . "</td>\n";
	echo "<td>". $stats[$key]['highway_tot'] . "</td>\n";
	echo "<td>". $stats[$key]['highway_len_tot'] . "</td>\n";
	echo "<td>". $stats[$key]['highway_nome'] . "</td>\n";
	echo "<td>". $stats[$key]['highway_len_nome'] . "</td>\n";
	echo "</tr>\n";
}

pg_close($conn);

?>
</pre>
</body>
</html>
