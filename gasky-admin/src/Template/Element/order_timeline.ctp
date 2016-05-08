<div class="box box-primary">
  <div class="box-header with-border">
    <h3 class="box-title"><?= __('Order Timeline'); ?></h3>
  </div>

  <div class="box-body">
    <ul>
      <?php if (!empty($order->received_at)): ?>
        <li>
          <strong><?= __('Received:') ?></strong>
          <?= $this->Time->format($order->received_at, 'MMMM d, yyyy @ h:mm a z', null, 'America/New_York') ?>
        </li>
      <?php endif; ?>
      
      <?php if (!empty($order->delivering_at)): ?>
        <li>
          <strong><?= __('Delivering:') ?></strong>
          <?= $this->Time->format($order->delivering_at, 'MMMM d, yyyy @ h:mm a z', null, 'America/New_York') ?>
        </li>
      <?php endif; ?>
      
      <?php if (!empty($order->delivered_at)): ?>
        <li>
          <strong><?= __('Delivered:') ?></strong>
          <?= $this->Time->format($order->delivered_at, 'MMMM d, yyyy @ h:mm a z', null, 'America/New_York') ?>
        </li>
      <?php endif; ?>
      
      <?php if (!empty($order->finalized_at)): ?>
        <li>
          <strong><?= __('Settled At:') ?></strong>
          <?= $this->Time->format($order->finalized_at, 'MMMM d, yyyy @ h:mm a z', null, 'America/New_York') ?>
        </li>
      <?php endif; ?>
      
      <?php if (!empty($order->finalized_at) && $order->paid == 0): ?>
        <li>
          <strong><?= __('Payment Failed!') ?></strong>
        </li>
      <?php endif; ?>
      
      <?php if (!empty($order->payment_at)): ?>
        <li>
          <strong><?= __('Paid At:') ?></strong>
          <?= $this->Time->format($order->payment_at, 'MMMM d, yyyy @ h:mm a z', null, 'America/New_York') ?>
        </li>
      <?php endif; ?>
      
      <?php if (!empty($order->completed_at)): ?>
        <li>
          <strong><?= ($order->status == 'cancelled' ? __('Cancelled:') : __('Completed:')) ?></strong>
          <?= $this->Time->format($order->completed_at, 'MMMM d, yyyy @ h:mm a z', null, 'America/New_York') ?>
        </li>
      <?php endif; ?>
    </ul>
  </div>
</div>