<!DOCTYPE html>
<html>
  <?= $this->element('head') ?>

  <body class="sidebar-mini skin-black fixed">
    <div class="wrapper">
      <?= $this->element('header') ?>

      <?= $this->element('main_sidebar') ?>

      <div class="content-wrapper">
        <?= $this->fetch('content') ?>
      </div>

      <?= $this->element('footer') ?>

      <?= $this->element('foot') ?>
    </div>
  </body>
</html>
