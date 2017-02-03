<?php include('header.php');
?>

    <ol class="breadcrumb">
     <li><span class="glyphicon glyphicon-folder-open" data-toggle="tooltip" data-placement="bottom" title="navigazione"
style="color:black;padding-right: 6px;"> </span>

    <?php
    if (isset($region)) {
        echo " <a href=" . '"' . $baseUrl . '">'.__('EXTRACTS').'</a></li>';
    } else {
         echo ' '.__('EXTRACTS').'</li>';
    }
?>

<?php
if (isset($region)) {
    echo '<li><a href="' . $baseUrl . "/" . rawurlencode($region) . '">'.$region.'</a></li>';
}

        ?>
        <?php if (isset($region) && isset($province)) {
            echo '<li>'.$province.'</li>';
}
        ?>
        <?php if (isset($region) && isset($province) && isset($municipality)) {
            echo '<li>'.$municipality.'</li>';
}
        ?>
    </ol>

<style>
.capitalLetter{font-weight:bold;text-transform:uppercase;}
.listContainer a {display:inline-block; margin:0 5px;}
</style>

    <div class="container-fluid">
    <div class="row">
        <div class="col-md-12 listContainer">
            <?php
                echo '<h3 class="text-left text-primary">'.__('LIST').' ';
            if (!isset($province)) {
                echo __('AVAILABLE_REGIONS');
            } /* appare solo nella home ESTRATTI */
            if (isset($province)) {
                echo __('MUNICIPALITIES_IN_PROVINCE').' '.$province;
            }
                    echo '</h3>';
                $letter='';
                          $url=$baseUrl;
            if (isset($region)) {
                $url.='/'.rawurlencode($region);
            }
            if (isset($province)) {
                $url.='/'.rawurlencode($province);
            }

            foreach ($list as $row) {
                      $firstLetter=substr($row['name'], 0, 1);
                if ($letter!=$firstLetter) {
                    echo "<span class='capitalLetter'>".$firstLetter."</span>";
                    $letter=$firstLetter;
                }
                echo "\n<a href='".$url."/".rawurlencode($row['safe_name'])."'>".$row['name']."</a> ";
            }
                ?>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12 listContainer">
<p><b>Benvenuto sul portale Estratti di OpenStreetMap!</b></p>
<p>In questo sito web mettiamo a disposizione per il download libero e gratuito estratti del database OpenStreetMap Italia ritagliati per Regione e Comune. I dati sono aggiornati quotidianamente per tutti i formati disponibili.</p>
<p>Il progetto ha l’obiettivo di rendere accessibili i dati OpenStreetMap grazie ad un sistema semplice e facilitarne l’utilizzo per eseguire test o costruire prodotti specifici.</p>
<p>Se volete inviarci domande, suggerimenti o richieste specifiche potete utilizzare la pagina Contatti.</p>
<p><b>Cosa trovate:</b></p>
<p>Gli estratti delle singole Regioni sono in formato SHP e PBF, il poligono dei confini è in POLY.<br/>
Le aree sono delimitate o dal rettangolo che le inscrive o dal confine amministrativo.<br/>
Per i Comuni i formati sono SHP, PBF, OSM, Spatialite, i confini in POLY.</p>
<p>In about trovate i dettagli sui vari formati e la suddivisione dei layer negli shapefile.</p>
        </div>
    </div>
<?php include('footer.php');?>
