<?php $this->assign('title', 'Gasky Promos'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Promos') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li class="active"><?= __('Promos') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-xs-12">
      <div class="box">
        <div class="box-body">
          <table class="table table-bordered table-striped all-controls">
            <thead>
              <tr>
                <th><?= __('Code') ?></th>
                <th><?= __('Discount') ?></th>
                <th><?= __('Uses') ?></th>
                <th><?= __('Max Uses') ?></th>
                <th><?= __('Expires') ?></th>
                <th><?= __('Actions') ?></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($promos as $promo): ?>
                <tr>
                  <td><?= h($promo->code) ?></td>
                  <td>
                    <?php if ($promo->percent_off > 0): ?>
                      <?= h($promo->percent_off) ?>%
                    <?php else: ?>
                      $<?= number_format($promo->dollar_amount_off, 2) ?>
                    <?php endif; ?>
                  </td>
                  <td><?= h($promo->uses) ?></td>
                  <td><?= h($promo->max_uses) ?></td>
                  <td><?= $this->Time->format($promo->expires, 'M/dd/yyyy, h:mm a z', null, 'America/New_York') ?></td>
                  <td><?= $this->Form->postLink(__('Delete'), ['action' => 'delete', $promo->id], ['confirm' => __('Are you sure you want to delete {0}?', $promo->code)]) ?></td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      </div>
      
      <?= $this->Flash->render() ?>
      <div class="box box-primary">
        <div class="box-header with-border">
          <h3 class="box-title">Create New Promo</h3>
        </div>
        <?= $this->Form->create($newPromo) ?>
          <div class="box-body">
            <?= $this->Form->input('code', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('percent_off', [
              'required' => true,
              'step' => 1,
              'default' => '0',
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('dollar_amount_off', [
              'required' => true,
              'step' => .01,
              'default' => '0.00',
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('max_uses', [
              'required' => false,
              'step' => 1,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('expires', [
              'type' => 'text',
              'required' => true,
              'class' => 'form-control'
            ]) ?>
          </div>
          <div class="box-footer">
            <?= $this->Form->button(__('Create Promo'), [
              'class' => 'btn btn-primary'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
</section>
