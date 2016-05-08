<?php $this->assign('title', 'Gasky Service Areas'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Service Areas') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Operations') ?></li>
    <li class="active"><?= __('Service Areas') ?></li>
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
                <th><?= __('Name') ?></th>
                <th><?= __('Boundaries (Lat, Lng)') ?></th>
                <th><?= __('Actions') ?></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($serviceAreas as $serviceArea): ?>
                <tr>
                  <td><?= h($serviceArea->name) ?></td>
                  <td>
                    <?php foreach ($serviceArea['bounds'] as $bounds): ?>
                      (<?= implode(', ', $bounds) ?>)
                    <?php endforeach; ?>
                  </td>
                  <td>
                    <?= $this->Html->link(__('Edit'), ['action' => 'edit', $serviceArea->id]) ?> -
                    <?= $this->Form->postLink(__('Delete'), ['action' => 'delete', $serviceArea->id], ['confirm' => __('Are you sure you want to delete {0}?', $serviceArea->name)]) ?>
                  </td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      </div>

      <?= $this->Flash->render() ?>
      <div class="box box-primary">
        <div class="box-header with-border">
          <h3 class="box-title">Create New Service Area</h3>
        </div>
        <?= $this->Form->create($newServiceArea) ?>
          <div class="box-body">
            <?= $this->Form->input('name', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <div id="form-coordinates">
              <?php if ($this->Form->isFieldError('bounds')): ?>
                <?= $this->Form->error('bounds'); ?>
              <?php endif; ?>
              <?php $initialPairs = count($newServiceArea->lat) > 3 ? count($newServiceArea->lat) : 3; ?>
              <?php for ($i = 0; $i < $initialPairs; $i++): ?>
                <div class="row coordinate-pair">
                  <div class="col-xs-6">
                    <?= $this->Form->input('lat[]', [
                      'label' => __('Latitude'),
                      'type' => 'number',
                      'step' => '0.000001',
                      'value' => $newServiceArea->lat[$i],
                      'id' => null,
                      'class' => 'form-control',
                    ]) ?>
                  </div>
                  <div class="col-xs-6">
                    <?= $this->Form->input('lng[]', [
                      'label' => __('Longitude'),
                      'type' => 'number',
                      'step' => '0.000001',
                      'value' => $newServiceArea->lng[$i],
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
            <?= $this->Form->button(__('Create Service Area'), [
              'class' => 'btn btn-primary'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
</section>
