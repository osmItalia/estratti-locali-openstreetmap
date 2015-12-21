<?php
require 'flight/Flight.php';
require 'sendMail.php';
require 'lang.php';

Flight::register('db', 'PDO', array('pgsql:host=localhost;port=5432;dbname=osm;user=osm;'));

Flight::route('/about', function () {
    checkLang();
    Flight::render(
        'about.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => 'About')
    );
});

Flight::route('GET /contact', function () {
    checkLang();
    Flight::render(
        'contact.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => 'Contact')
    );
});

Flight::route('POST /contact', function () {
    $result=sendMail();
    Flight::render(
        'contact.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => 'Contact','mailResult'=>$result)
    );
});

Flight::route('/', function () {
    checkLang();
    $db = Flight::db();
    $query = "SELECT osm_id,cod_istat,name,safe_name FROM it_regioni reg ORDER BY safe_name";
    $res = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
    Flight::render(
        'list.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => 'Italy',
            'list'=>$res)
    );
});

Flight::route('/@region', function ($region) {
    checkLang();
    $db = Flight::db();
    $query = "SELECT reg.osm_id,reg.cod_istat,reg.name,reg.safe_name,reg.bbox,ST_AsGeoJSON(ST_Simplify(reg.geom,0.0001),5)";
    $query .=" FROM it_regioni reg WHERE reg.safe_name=".$db->quote($region);
    $res = $db->query($query);
    $mainData=$res->fetchAll();
    if (count($mainData)==0) {
        return Flight::notFound();
    }
    $mainData=$mainData[0];

//name with diacritics for display
    $realName=$mainData['name'];

    $query = "SELECT stat.* FROM it_regioni reg JOIN it_stats stat ON reg.osm_id = stat.osm_id";
    $query .= " WHERE reg.cod_istat=".$db->quote($mainData['cod_istat'])." AND data > (CURRENT_DATE - 30) ORDER BY data ASC";
    $res = $db->query($query);
    $stats=$res->fetchAll();

    $query = "SELECT pro.osm_id,pro.cod_istat,pro.name,pro.safe_name FROM it_province pro JOIN it_regioni reg";
    $query .= " ON pro.cod_istat_reg=reg.cod_istat WHERE reg.cod_istat=".$db->quote($mainData['cod_istat'])." ORDER BY pro.safe_name";
    $res = $db->query($query);
    $res=$res->fetchAll(PDO::FETCH_ASSOC);

    Flight::render(
        'extractAndList.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => $realName,
            'region_safe' => $region,
            'region' => $realName,
            'list' => $res,
            'mainData' => $mainData,
            'stats' => $stats)
    );
});


Flight::route('/@region/@province', function ($region, $province) {
    checkLang();
    $db = Flight::db();
    $query = "SELECT com.osm_id,com.cod_istat,com.name,com.safe_name FROM it_province pro JOIN it_regioni reg ON pro.cod_istat_reg=reg.cod_istat JOIN it_comuni com ON com.cod_istat_reg=reg.cod_istat AND com.cod_istat_pro=pro.cod_istat WHERE reg.safe_name=".$db->quote($region)." AND pro.safe_name=".$db->quote($province)." ORDER BY name";
    $res = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
    Flight::render(
        'list.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => $province.', '.$region,
            'region' => $region,
            'province' => $province,
            'list'=>$res)
    );
});

Flight::route('/@region/@province/@municipality', function ($region, $province, $municipality) {
    checkLang();
    $db = Flight::db();
    $query = "SELECT com.osm_id,com.cod_istat,com.name, com.safe_name, pro.name AS prov_name, reg.name AS reg_name,com.bbox,ST_AsGeoJSON(ST_Simplify(com.geom,0.0001),5) FROM it_regioni reg JOIN it_province pro ON reg.cod_istat = pro.cod_istat_reg JOIN it_comuni com ON pro.cod_istat=com.cod_istat_pro WHERE com.safe_name=".$db->quote($municipality)." AND pro.safe_name=".$db->quote($province);
    $res = $db->query($query);

    $mainData=$res->fetchAll();
    if (count($mainData)==0) {
        return Flight::notFound();
    }
    $mainData=$mainData[0];

    $proName=$mainData['prov_name'];
    $regName=$mainData['reg_name'];
    $munName=$mainData['name'];

    $query = "SELECT stat.* FROM it_comuni com JOIN it_stats stat ON com.osm_id = stat.osm_id WHERE com.cod_istat=".$db->quote($mainData['cod_istat'])." AND data > (CURRENT_DATE - 30) ORDER BY data ASC";
    $res = $db->query($query);
    $stats=$res->fetchAll();

    Flight::render(
        'extract.php',
        array(
            'baseUrl'=>Flight::request()->base,
            'pTitle' => $municipality.', '.$province.', '.$region,
            'region' => $regName,
            'region_safe' => $region,
            'province' => $proName,
            'province_safe'=> $province,
            'municipality' => $munName,
            'municipality_safe'=> $municipality,
            'mainData' => $mainData,
            'stats' => $stats)
    );
});

Flight::map('notFound', function () {
    echo "404";
});

Flight::start();
