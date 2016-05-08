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
          <h3 class="box-title"><?= __('User Feedback'); ?></h3>
        </div>
        <div class="box-body">
          <?php if (!empty($order->order_rating)): ?>
            <ul class="list-unstyled">
              <li>
                <?php for ($i = 0; $i < 5; $i++): ?>
                  <?php if ($i < $order->order_rating->rating): ?>
                    <i class="fa fa-star fa-lg"></i>
                  <?php else: ?>
                    <i class="fa fa-star-o fa-lg"></i>
                  <?php endif; ?>
                <?php endfor; ?>
              </li>
              <?php if (!empty($order->order_rating->details)): ?>
                <li><strong><?= __('Details:') ?></strong> <?= h($order->order_rating->details) ?></li>
              <?php endif; ?>
            </ul>
          <?php else: ?>
            <?= __('Awaiting customer feedback.') ?>
          <?php endif; ?>
        </div>
      </div>
    </div>
  </div>
  
  <?= $this->element('order_information') ?>
</section>