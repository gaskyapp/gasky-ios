<?php $this->assign('title', 'Gasky Service Area Edit'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Service Areas') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li><?= $this->Html->link(__('Service Areas'), ['action' => 'index']) ?></li>
    <li class="active"><?= __('Edit Service Area') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-xs-12">
      <?= $this->Flash->render() ?>
      <div class="box box-primary">
        <div class="box-header with-border">
          <h3 class="box-title">Edit Service Area</h3>
        </div>
        <?= $this->Form->create($serviceArea) ?>
          <div class="box-body">
            <?= $this->Form->input('name', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <div id="form-coordinates">
              <?php if ($this->Form->isFieldError('bounds')): ?>
                <?= $this->Form->error('bounds'); ?>
              <?php endif; ?>
              <?php $initialPairs = count($serviceArea->lat) > 3 ? count($serviceArea->lat) : 3; ?>
              <?php for ($i = 0; $i < $initialPairs; $i++): ?>
                <div class="row coordinate-pair">
                  <div class="col-xs-6">
                    <?= $this->Form->input('lat[]', [
                      'label' => __('Latitude'),
                      'type' => 'number',
                      'step' => '0.000001',
                      'value' => $serviceArea->lat[$i],
                      'id' => null,
                      'class' => 'form-control',
                    ]) ?>
                  </div>
                  <div class="col-xs-6">
                    <?= $this->Form->input('lng[]', [
                      'label' => __('Longitude'),
                      'type' => 'number',
                      'step' => '0.000001',
                      'value' => $serviceArea->lng[$i],
                      'id' => null,
                      'class' => 'form-control',
                    ]) ?>
                  </div>
                </div>
              <?php endfor; ?>
            </div>
          </div>
          <div class="box-footer">
            <?= $this->Html->link('<i class="fa fa-map-marker" aria-hidden="true"></i> ' . __('Add Coordinate'), '#', [
              'id' => 'add-coordinate',
              'class' => 'btn btn-success pull-right',
              'escape' => false
            ]) ?>
            <?= $this->Form->button(__('Apply Changes'), [
              'class' => 'btn btn-primary'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
</section>
