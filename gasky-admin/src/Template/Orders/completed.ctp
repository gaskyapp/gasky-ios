<?php $this->assign('title', 'Gasky Completed Orders'); ?>

<section class="content-header">
  <h1><?= __('Completed Orders') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li class="active"><?= __('Completed Orders') ?></li>
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
                <th><?= __('Customer') ?></th>
                <th><?= __('Status') ?></th>
                <th><?= __('Total') ?></th>
                <th><?= __('Actions') ?></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($orders as $order): ?>
                <tr>
                  <td data-order="<?= $order->delivery_date->format('Ymd') ?>"><?= h($order->delivery_date->format('F j, Y')) ?></td>
                  <td>
                    <?= $this->Html->link(h($order->user->name), [
                      'controller' => 'Users', 'action' => 'view', $order->user->id
                    ]) ?>
                  </td>
                  <td><?= h($order->status) ?></td>
                  <td>$<?= number_format($order->total, 2) ?></td>
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
