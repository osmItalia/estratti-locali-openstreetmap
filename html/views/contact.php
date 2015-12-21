<?php include('header.php');?>

<h1><?php echo __('CONTACT_HEAD');?></h1>

   <div class="jumbotron">
        <p><?php echo __('CONTACT_JUMBO');?></p>
    </div>

    <?php if (isset($mailResult)&& $mailResult == true) : ?>
        <div class="col-md-6 col-md-offset-3">
            <div class="alert alert-success text-center"><?php echo __('CONTACT_OK');?></div>
        </div>
    <?php else : ?>
        <?php if (isset($mailResult)&& $mailResult == true) : ?>
        <div class="col-md-5 col-md-offset-4">
            <div class="alert alert-danger text-center"><?php echo __('CONTACT_FAIL');?></div>
        </div>
        <?php endif; ?>

    <div class="col-md-6 col-md-offset-3">
        <form action="<?php echo $_SERVER['REQUEST_URI']; ?>" id="contact-form" class="form-horizontal" role="form" method="post">
            <div class="form-group">
                <label for="name" class="col-lg-2 control-label"><?php echo __('CONTACT_NAME');?></label>
                <div class="col-lg-10">
                    <input type="text" class="form-control" id="form-name" name="form-name" placeholder="<?php echo __('CONTACT_NAME');?>" required>
                </div>
            </div>
            <div class="form-group">
                <label for="email" class="col-lg-2 control-label"><?php echo __('CONTACT_EMAIL');?></label>
                <div class="col-lg-10">
                    <input type="email" class="form-control" id="form-email" name="form-email" placeholder="<?php echo __('CONTACT_EMAIL');?>" required>
                </div>
            </div>
            <div class="form-group">
                <label for="tel" class="col-lg-2 control-label"><?php echo __('CONTACT_PHONE');?></label>
                <div class="col-lg-10">
                    <input type="tel" class="form-control" id="form-tel" name="form-tel" placeholder="<?php echo __('CONTACT_PHONE');?>">
                </div>
            </div>
            <div class="form-group">
                <label for="message" class="col-lg-2 control-label"><?php echo __('CONTACT_MESSAGE');?></label>
                <div class="col-lg-10">
                    <textarea class="form-control" rows="3" id="form-message" name="form-message" placeholder="<?php echo __('CONTACT_MESSAGE');?>" required></textarea>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-2"></div>
                <div class="col-lg-1">
                <input class="form-control" type="checkbox" id="form-sendCopy" name="form-sendCopy"/>
                </div>
                <div class="col-lg-9">
                <label for="sendCopy" class="control-label"><?php echo __('CONTACT_CONFIRM');?></label>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-2 col-lg-10">
                    <button type="submit" class="btn btn-default"><?php echo __('CONTACT_SEND');?></button>
                </div>
            </div>
        </form>
    </div>
    <?php endif; ?>

    <!--[if lt IE 9]>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <![endif]-->
    <!--[if gte IE 9]><!-->
        <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <!--<![endif]-->
    <script type="text/javascript" src="../assets/js/contact-form.js"></script>

<?php include('footer.php');?>
