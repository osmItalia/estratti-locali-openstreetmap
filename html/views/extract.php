<?php include('header.php');
?>

    <ol class="breadcrumb">
     <li><a href="<?php echo $baseUrl; ?>"><span class="glyphicon glyphicon-folder-open" data-toggle="tooltip"
     data-placement="bottom" title="navigazione" style="color:black;padding-right: 6px;"> </span><?php echo __('EXTRACTS')?></a></li>
        <?php if (isset($region)) {
            echo '<li><a href="'.$baseUrl.'/'.rawurlencode($region_safe).'/">'.$region.'</a></li>';
}
        ?>
        <?php if (isset($region) && isset($province)) {
            echo '<li><a href="'.$baseUrl.'/'.rawurlencode($region_safe).'/'.rawurlencode($province_safe).'/">'.$province.'</a></li>';
}
        ?>
        <?php if (isset($region) && isset($province)  && isset($municipality)) {
            echo '<li>'.$municipality.'</li>';
}
        ?>
    </ol>
    <div class="row">
    <?php
    $statusTable=[];
    foreach ($stats as $row) {
        $statusTable[$row['data']][$row['k']]=$row['v'];
    }
    ?>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="jumbotron well">
<?php
$dt=filemtime("/srv/downloads/italy-latest.osm.pbf");
?>
                <h2>Estratti OpenStreetMap</h2>
                <p><?php echo __('JUMBO_INTRO_MUNICIPALITY')." ".$municipality."".__('JUMBO_1')." ".date("H:i", $dt)." ".__('JUMBO_2');
                    echo " ".date("d/m/Y", $dt)." ".__('JUMBO_3_MUNICIPALITY');
                ?></p>
            </div>
        </div>
        <div class="col-md-6">
            <div class="media">
    <link rel="stylesheet" href="<?php echo $baseUrl?>/assets/css/leaflet.css">
    <script src="<?php echo $baseUrl?>/assets/js/leaflet.js"></script>
                <!-- 4:3 aspect ratio -->
                <div class="embed-responsive embed-responsive-4by3">
                 <div id="map" style="width:100%;height:100%;min-height:355px;";></div>
                <script>
                var map = L.map('map').setView([51.505, -0.09], 13);

                L.tileLayer('https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                }).addTo(map);
                <?php if (isset($mainData['st_asgeojson'])) :?>
                var geojsonFeature=<?php echo $mainData['st_asgeojson'];?>;
                var geojsonLayer= L.geoJson(geojsonFeature).addTo(map);
                map.fitBounds(geojsonLayer.getBounds(),{padding:[15,15]});
                <?php endif; ?>
                <?php if (isset($mainData['bbox'])) :?>
                var rectangle = L.rectangle(<?php echo $mainData['bbox'];?>, {color: "#ff7800", weight: 1}).addTo(map);
                <?php endif; ?>
                </script>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid">
    <div class="row">
        <div class="col-md-12">
            <h3 class="text-left text-primary"><?php echo __('DOWNLOAD_AND_STATISTICS');?></h3>
            <p class="text-left"><?php echo __('DESC_DOWNLOAD_1_MUNICIPALITY')." ".$municipality.__('DESC_DOWNLOAD_2');?></p>

        </div>
    </div>
    <div class="row">
        <div class="col-md-6">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th><?php echo __('DATA');?></th>
                        <th><?php echo __('STRADE');?></th>
                        <th><?php echo __('CIVICI');?></th>
                        <th><?php echo __('EDIFICI');?></th>
                    </tr>
                </thead>
                <tbody>
                <?php
                foreach ($statusTable as $date => $k) {
                    echo "<tr>";
                    echo "<td>".$date."</td>";
                    if (isset($k['highway_len_tot'])) {
                        $highway=number_format(($k['highway_len_tot']/1000), 3, ',', '.')." km";
                    }
                    echo "<td>".$highway."</td>";
                    if (isset($k['civici'])) {
                        $civici=$k['civici'];
                    }
                    echo "<td>".$civici."</td>";
                    if (isset($k['buildings'])) {
                        $buildings=$k['buildings'];
                    }
                    echo "<td>".$buildings."</td>";
                    echo "</tr>";
                }
                ?>

                </tbody>
            </table>
            <a href="<?php echo Flight::request()->base.Flight::request()->url.(substr(Flight::request()->url,-1)!="/"?"/":"").'stats' ?>"><?php echo __('HISTORICAL_DATA'); ?></a>
        </div>

        <div class="col-md-6">
<?php
$filePath='/comuni/shape/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.zip';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> SHP (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif;

$filePath='/comuni/pbf/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.pbf';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> PBF (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif;

$filePath='/comuni/osm/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.osm.zip';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> OSM (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif;

$filePath='/comuni/sqlite/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.sqlite.zip';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> Spatialite (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif;

$filePath='/comuni/poly/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.poly';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> POLY (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif;

$filePath='/comuni/pbf_r/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.R.pbf';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> PBF [cut] (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif;

$filePath='/comuni/osm_r/'.$mainData['cod_istat'].'---'.$mainData['safe_name'].'.R.osm.zip';
if(file_exists($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath)): ?>
<a href="<?php echo $baseUrl.$filePath;?>">
<button type="button" class="btn btn-default btn-lg">
  <span class="glyphicon glyphicon-download-alt"></span> OSM [cut] (<?php echo number_format(filesize($_SERVER['DOCUMENT_ROOT'].'/estratti'.$filePath) / 1048576, 2);?> MB)
</button>
</a>
<?php endif; ?>
        </div>
    </div>
</div>
<?php include('footer.php');?>
