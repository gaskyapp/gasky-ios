<?php $this->assign('title', 'Gasky Pricing'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Pricing') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li class="active"><?= __('Pricing') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-md-6">
      <?= $this->Flash->render() ?>
      <div class="box box-primary">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Regular Gas') ?></h3>
          <div class="box-tools pull-right">
            <span class="label label-info"><?= __('Updated:') ?> <?= $this->Time->format($regularGas->updated_at, 'M/dd/yyyy, h:mm a z', null, 'America/New_York') ?></span>
          </div>
        </div>
        <?= $this->Form->create($regularGas) ?>
          <div class="box-body">
            <?= $this->Form->input('cost', [
              'label' => false,
              'value' => number_format($regularGas->cost, 2),
              'required' => true,
              'class' => 'form-control'
            ]) ?>
          </div>
          <div class="box-footer">
            <?= $this->Form->button(__('Apply Changes'), [
              'class' => 'btn btn-primary'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
</section>
