<?php $this->assign('title', 'Gasky View Order'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Order') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li><?= $this->Html->link(__('Orders'), ['action' => 'index']) ?></li>
    <li class="active"><?= __('View Order') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-md-6">
      <?= $this->element('order_timeline') ?>
    </div>
    <div class="col-md-6">
      <?= $this->Flash->render() ?>
      <div class="box box-danger">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Payment Failed'); ?></h3>
        </div>
        <div class="box-body">
          <?= $this->Form->postLink(__('Retry Payment'),
            ['action' => 'retryPayment', $order->id],
            ['class' => 'btn btn-block btn-danger btn-lg']) ?>
        </div>
      </div>
    </div>
  </div>
  
  <?= $this->element('order_information') ?>
</section>