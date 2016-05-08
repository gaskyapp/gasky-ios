<?php $this->assign('title', 'Gasky Customer Data'); ?>

<section class="content-header">
  <h1><?= __('Customer Data') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Customers') ?></li>
    <li><?= $this->Html->link(__('Database'), ['action' => 'index']) ?></li>
    <li class="active"><?= __('View Customer') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-md-6">
      <div class="box box-widget widget-user-2">
        <div class="widget-user-header bg-blue">
          <div class="widget-user-image">
            <div class="img-circle img-bg" style="background-image: url(https://preview.ericlorentz.com/gasky/uploads/photos/<?= $user->photo ?>)"></div>
          </div>
          <h3 class="widget-user-username"><?= ($user->name ? h($user->name) : __('Name Not Provided')) ?></h3>
          <h5 class="widget-user-desc">Customer Since <?= $this->Time->format($user->created_at, 'MMMM dd, yyyy', null, 'America/New_York') ?></h5>
        </div>
        <div class="box-footer no-padding">
          <ul class="nav nav-stacked">
            <?php if (!empty($user->phone)): ?>
              <li><a href="tel:<?= str_replace('.', '-', $user->phone) ?>"><strong><?= __('Phone Number:') ?></strong> <?= h($user->phone) ?></a></li>
            <?php endif; ?>
            <li><a href="mailto:<?= $user->email ?>"><strong><?= __('Email Address:') ?></strong> <?= h($user->email) ?></a></li>
          </ul>
        </div>
      </div>
      <div class="box box-success">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Default Payment Method') ?></h3>
        </div>
        <div class="box-body no-padding list-padding">
          <ul class="nav nav-stacked">
            <?php if (!empty($user->payment_methods)): ?>
              <li><strong><?= __('Card:') ?></strong> <?= h($user->payment_methods[0]->card_type) ?> ...<?= h($user->payment_methods[0]->digits) ?></li>
              <li><strong><?= __('Expiration:') ?></strong> <?= h($user->payment_methods[0]->expiration_date) ?></li>
              <li><strong><?= __('Billing Zip:') ?></strong> <?= h($user->payment_methods[0]->zip) ?></li>
            <?php else: ?>
              <li><strong><?= __('Payment information not provided.') ?></strong></li>
            <?php endif; ?>
          </ul>
        </div>
      </div>
      <div class="box box-info">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Order History') ?></h3>
        </div>
        <div class="box-body">
           <table class="table table-bordered table-striped only-paginate">
             <thead>
               <tr>
                 <th><?= __('Date') ?></th>
                 <th><?= __('Status') ?></th>
                 <th><?= __('Total') ?></th>
               </tr>
             </thead>
             <tbody>
               <?php foreach ($user->orders as $order): ?>
                 <tr>
                   <td><?= h($order->delivery_date) ?></td>
                   <td>
                     <?= $this->Html->link(h($order->status), [
                       'controller' => 'Orders',
                       'action' => 'view',
                       $order->id
                     ]) ?>
                   </td>
                   <td>$<?= number_format($order->total, 2) ?></td>
                 </tr>
               <?php endforeach; ?>
             </tbody>
           </table>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="box box-warning">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Vehicle Information') ?></h3>
        </div>
        <div class="box-body no-padding list-padding">
          <ul class="nav nav-stacked">
            <?php if (!empty($user->vehicle)): ?>
              <li><strong><?= __('Vehicle:') ?></strong> <?= h($user->vehicle['color']) ?> <?= h($user->vehicle['year']) ?> <?= h($user->vehicle['make']) ?> <?= h($user->vehicle['model']) ?></li>
              <li><strong><?= __('Plates:') ?></strong> <?= h($user->vehicle['plates']) ?></li>
              <?php if (!empty($user->vehicle['photo'])): ?>
                <li>
                  <?= $this->Html->image('https://preview.ericlorentz.com/gasky/uploads/vehicles/' . $user->vehicle['photo'], [
                    'alt' => __('User Vehicle'),
                    'class' => 'center-block img-responsive'
                  ]) ?>
                </li>
              <?php endif; ?>
            <?php else: ?>
              <li><strong><?= __('Vehicle information not provided.') ?></strong></li>
            <?php endif; ?>
          </ul>
        </div>
      </div>
    </div>
  </div>
</section>
