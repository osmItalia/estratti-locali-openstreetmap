<?php
$row = 1;
/*
Il formato della bbox è del tipo
2 3
1 4
e il quinto vertice è uguale al primo

Nel file sorgente di sbiribizio le bbox sono comoste come (minlon,minlat,maxlon,maxlat)

Lanciato da browser o terminale passando il csv e il file di destinazione, l'output è un geojson
*/

if(php_sapi_name()=="cli")
{
    $in=$argv[1];
    $out=$argv[2];
}
else
{
    $in=$_GET['in'];
    $out=$_GET['out'];
}

$geo=array('type'=>"FeatureCollection",'features'=>array());
if (($handle = fopen($in, "r")) !== FALSE) {
    while (($data = fgetcsv($handle, 1000, "|")) !== FALSE) {
       if($data[0]===NULL) continue;
       $relid=$data[0];
       $name=$data[1];
       $bbox=$data[2];
       $coord=explode(',',$bbox);
       $c2bbox=array(array(array($coord[0],$coord[1]),array($coord[0],$coord[3]),array($coord[2],$coord[3]),array($coord[2],$coord[1]),array($coord[0],$coord[1])));
       $questo=array('type'=>"Feature",'properties'=>array('id'=>$relid,'name'=>$name),'bbox'=>$coord,'geometry'=>array('type'=>'Polygon','coordinates'=>$c2bbox));
       $geo['features'][]=$questo;
    }
    fclose($handle);
}

file_put_contents($out, json_encode($geo,JSON_NUMERIC_CHECK));
?>
