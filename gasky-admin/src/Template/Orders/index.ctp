<?php $this->assign('title', 'Gasky Open Orders'); ?>

<section class="content-header">
  <h1><?= __('Open Orders') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li class="active"><?= __('Open Orders') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-xs-12">
      <div class="box">
        <div class="box-body">
          <table class="table table-bordered table-striped all-controls" data-order="[[0, &quot;desc&quot;]]">
            <thead>
              <tr>
                <th><?= __('Delivery Date') ?></th>
                <th><?= __('Delivery Hour') ?></th>
                <th><?= __('Customer') ?></th>
                <th><?= __('Status') ?></th>
                <th><?= __('Location') ?></th>
                <th><?= __('Actions') ?></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($orders as $order): ?>
                <tr>
                  <td data-order="<?= $order->delivery_date->format('Ymd') ?>"><?= h($order->delivery_date->format('F j, Y')) ?></td>
                  <td><?= h(date('g:i a', strtotime($order->delivery_time . ':00'))) ?></td>
                  <td>
                    <?= $this->Html->link(h($order->user->name), [
                      'controller' => 'Users', 'action' => 'view', $order->user->id
                    ]) ?>
                  </td>
                  <?php if (empty($order->delivering_at)): ?>
                    <td class="info"><?= __('Received') ?> <i class="fa fa-envelope-o"></i></td>
                  <?php elseif (empty($order->delivered_at)): ?>
                    <td class="warning"><?= __('Delivering') ?> <i class="fa fa-tachometer"></i></td>
                  <?php elseif (empty($order->finalized_at)): ?>
                    <td class="success"><?= __('Delivered') ?> <i class="fa fa-check"></i></td>
                  <?php elseif (!$order->paid): ?>
                    <td class="danger"><?= __('Payment Failed') ?> <i class="fa fa-times"></i></td>
                  <?php else: ?>
                    <td><?= __('Awaiting Feedback') ?> <i class="fa fa-comment"></i></td>
                  <?php endif; ?>
                  <td>
                    (<?= $this->Html->link(h($order->latitude . ', ' . $order->longitude),
                      h('http://maps.google.com/maps?q=' . $order->latitude . ',' . $order->longitude),
                      ['target' => '_blank']
                    ) ?>)
                  </td>
                  <td><?= $this->Html->link(__('View'), ['action' => 'view', $order->id]) ?></td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</section>
