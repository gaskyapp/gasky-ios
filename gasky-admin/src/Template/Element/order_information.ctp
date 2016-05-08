<div class="row">
  <div class="col-md-6">
    <div class="box box-warning">
      <div class="box-header with-border">
        <h3 class="box-title"><?= __('Delivery Time & Fuel Grade') ?></h3>
      </div>
      
      <div class="box-body">
        <h4><?= h($order->delivery_date->format('F j, Y')) ?> @ <?= h(date('g:i a', strtotime($order->delivery_time . ':00'))) ?> - <?= h($order->grade) ?></h4>
      </div>
    </div>
    
    <div class="box box-success">
      <div class="box-header with-border">
        <h3 class="box-title"><?= __('Delivery Location') ?></h3>
      </div>
      
      <div class="box-body no-padding list-padding">
        <ul class="nav nav-stacked">
          <li>
            <?= $this->Html->link(
              $this->Html->image(h('https://maps.googleapis.com/maps/api/staticmap?center=' . $order->latitude . ',' . $order->longitude .'&zoom=19&scale=2&size=600x450&maptype=hybrid&format=png&visual_refresh=true&markers=size:mid%7Ccolor:0xff0000%7Clabel:%7C' . $order->latitude . ',' . $order->longitude), [
              'alt' => __('View in Google Maps'),
              'class' => 'center-block img-responsive',
              'style' => 'max-width: 100%'
            ]), h('https://maps.google.com/maps?q=' . $order->latitude . ',' . $order->longitude), [
              'target' => '_blank',
              'style' => 'padding: 0',
              'escape' => false
            ]) ?>
          </li>
          <li><strong><?= __('Coordinates:') ?></strong> (<?= h($order->latitude) ?>, <?= h($order->longitude) ?>)</li>
          <li><strong><?= __('Address:') ?></strong> <?= h($order->location) ?></li>
          <li><strong><?= __('Details:') ?></strong> <?= h($order->details) ?></li>
        </ul>
      </div>
    </div>
  </div>
  
  <div class="col-md-6">
    <div class="box box-info">
      <div class="box-header with-border">
        <h3 class="box-title"><?= __('Customer Information') ?></h3>
      </div>
      <div class="box-body no-padding list-padding">
        <ul class="nav nav-stacked">
            <li style="padding: 0">
              <?= $this->Html->link('<strong>' . __('Customer:') . ' </strong>' . h($order->user->name), [
                'controller' => 'Users',
                'action' => 'view',
                $order->user->id
              ], ['escape' => false]) ?>
            </li>
            <li><strong><?= __('Vehicle:') ?></strong> <?= h($order->user->vehicle['color']) ?> <?= h($order->user->vehicle['year']) ?> <?= h($order->user->vehicle['make']) ?> <?= h($order->user->vehicle['model']) ?></li>
            <li><strong><?= __('Plates:') ?></strong> <?= h($order->user->vehicle['plates']) ?></li>
            <li>
              <?= $this->Html->image('https://preview.ericlorentz.com/gasky/uploads/vehicles/' . $order->user->vehicle['photo'], [
                'alt' => __('User Vehicle'),
                'class' => 'center-block img-responsive'
              ]) ?>
            </li>
        </ul>
      </div>
    </div>
  </div>
</div>