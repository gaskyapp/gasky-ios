<head>
  <?= $this->Html->charset() ?>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>
    <?= $this->fetch('title') ?>
  </title>
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <?= $this->Html->meta(array('name' => 'robots', 'content' => 'noindex')) ?>
  <?= $this->Html->meta('icon') ?>

  <?= $this->Html->meta([
    'link' => 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css',
    'rel' => 'stylesheet',
    'integrity' => 'sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7',
    'crossorigin' => 'anonymous'
  ]) ?>
  <?= $this->Html->meta([
    'link' => 'https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css',
    'rel' => 'stylesheet',
    'integrity' => 'sha384-MI32KR77SgI9QAPUs+6R7leEOwtop70UsjEtFEezfKnMjXWx15NENsZpfDgq8m8S',
    'crossorigin' => 'anonymous'
  ]) ?>
  <?= $this->Html->meta([
    'link' => 'https://code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css',
    'rel' => 'stylesheet',
    'integrity' => 'sha384-4r9SMzlCiUSd92w9v1wROFY7DlBc5sDYaEBhcCJR7Pm2nuzIIGKVRtYWlf6w+GG4',
    'crossorigin' => 'anonymous'
  ]) ?>

  <?= $this->Html->css('datatables.css') ?>
  <?= $this->Html->css('AdminLTE.min.css') ?>
  <?= $this->Html->css('skin-black.min.css') ?>
  <?= $this->Html->css('gasky') ?>

  <?= $this->fetch('meta') ?>
  <?= $this->fetch('css') ?>
</head>
