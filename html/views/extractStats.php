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
            echo '<li><a href="'.$baseUrl.'/'.rawurlencode($region_safe).'/'.rawurlencode($province_safe).'/'.rawurlencode($municipality_safe).'/">'.$municipality.'</a></li>';
}
        ?>
       <li><?php echo __('STATISTICS');?></li>
    </ol>
    <div class="row">
    <?php
    $statusTable=[];
    foreach ($stats as $row) {
        $statusTable[$row['data']][$row['k']]=$row['v'];
    }
    ?>
    </div>

    <div class="container-fluid">
    <div class="row">
        <div class="col-md-12">
            <h3 class="text-left text-primary"><?php echo __('STATISTICS');?></h3>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
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
        </div>
    </div>
</div>
<?php include('footer.php');?>
