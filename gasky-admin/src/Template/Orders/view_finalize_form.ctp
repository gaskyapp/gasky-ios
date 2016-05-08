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
          <h3 class="box-title"><?= __('Settle Order'); ?></h3>
        </div>

        <?= $this->Form->create($order, ['url' => ['action' => 'finalize', $order->id], 'type' => 'file']) ?>
          <div class="box-body">
            <?= $this->Form->input('gallons', [
              'value' => '0.000',
              'required' => true,
              'class' => 'form-control',
              'data-step' => .001
            ]) ?>
            <?= $this->Form->input('price_per_gallon', [
              'value' => number_format($regularPrice, 2),
              'required' => true,
              'class' => 'form-control',
              'data-step' => .01
            ]) ?>
            <?= $this->Form->input('gas_total', [
              'value' => '0.00',
              'required' => true,
              'class' => 'form-control',
              'data-step' => .01,
              'disabled' => true
            ]) ?>
            <?= $this->Form->input('image.image', [
              'required' => true,
              'class' => 'form-control',
              'type' => 'file'
            ]) ?>
            <?= $this->Form->input('delivery_fee', [
              'value' => '5.00',
              'required' => true,
              'class' => 'form-control',
              'data-step' => .01,
              'disabled' => true
            ]) ?>
            
            <?php if (!empty($order->promo)): ?>
              <div class="form-group">
                <strong><?= __('Promo Code:') ?></strong> <?= h($order->promo->code) ?>
                
                <?php if ($order->promo->percent_off > 0): ?>
                  (<span id="discount" data-type="percent" data-amount="<?= h($order->promo->percent_off) ?>"><?= h($order->promo->percent_off) ?>% <?= __('Off') ?></span>)
                <?php else: ?>
                  (<span id="discount" data-type="dollar" data-amount="<?= h($order->promo->dollar_amount_off) ?>">$<?= h($order->promo->dollar_amount_off) ?> <?= __('Off') ?></span>)
                <?php endif; ?>
              </div>
            <?php endif; ?>
            
            <h4><strong><?= __('Total:') ?></strong> $<span id="total">0.00</span></h4>
          </div>
          
          <div class="box-footer">
            <?= $this->Form->button(__('Settle Order'), [
              'class' => 'btn btn-block btn-danger btn-lg'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
  
  <?= $this->element('order_information') ?>
</section>