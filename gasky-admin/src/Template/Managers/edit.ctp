<?php $this->assign('title', 'Gasky Manager Edit'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Managers') ?></h1>

  <ol class="breadcrumb">
    <?php if ($activeManager['id'] == $manager->id): ?>
      <li><?= __('Update Information') ?></li>
    <?php else: ?>
      <li><?= __('Administration') ?></li>
      <li><?= $this->Html->link(__('Managers'), ['action' => 'index']) ?></li>
      <li class="active"><?= __('Edit Manager') ?></li>
    <?php endif; ?>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-xs-12">
      <?= $this->Flash->render() ?>
      <div class="box box-warning">
        <div class="box-header with-border">
          <h3 class="box-title">Edit Manager Account</h3>
        </div>
        <?= $this->Form->create($manager) ?>
          <div class="box-body">
            <?= $this->Form->input('name', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('username', [
              'required' => true,
              'class' => 'form-control',
              'disabled' => true
            ]) ?>
            <?= $this->Form->input('password', [
              'required' => false,
              'class' => 'form-control',
              'value' => ''
            ]) ?>
            <?= $this->Form->input('email', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('role', [
              'class' => 'form-control',
              'disabled' => true
            ]) ?>
          </div>
          <div class="box-footer">
            <?= $this->Form->button(__('Apply Changes'), [
              'class' => 'btn btn-info'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
</div>
