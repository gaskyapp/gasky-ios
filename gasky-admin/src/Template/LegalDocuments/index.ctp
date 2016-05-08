<?php $this->assign('title', 'Gasky Legal Information'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Legal Information') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Administration') ?></li>
    <li class="active"><?= __('Legal Information') ?></li>
  </ol>
</section>

<section class="content">
  <div class="row">
    <div class="col-xs-12">
      <?= $this->Flash->render() ?>
    </div>
    <div class="col-md-6">
      <div class="box box-primary">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Privacy Policy') ?></h3>
          <div class="box-tools pull-right">
            <span class="label label-info"><?= __('Updated:') ?> <?= $this->Time->format($privacyPolicy->modified, 'M/dd/yyyy', null, 'America/New_York') ?></span>
          </div>
        </div>
        <?= $this->Form->create($privacyPolicy) ?>
          <div class="box-body">
            <?= $this->Form->input('id', [
              'type' => 'hidden',
              'label' => false,
              'id' => null
            ]) ?>
            <?= $this->Form->input('body', [
              'label' => false,
              'required' => true,
              'id' => null,
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
    <div class="col-md-6">
      <div class="box box-primary">
        <div class="box-header with-border">
          <h3 class="box-title"><?= __('Terms & Conditions') ?></h3>
          <div class="box-tools pull-right">
            <span class="label label-info"><?= __('Updated:') ?> <?= $this->Time->format($termsConditions->modified, 'M/dd/yyyy', null, 'America/New_York') ?></span>
          </div>
        </div>
        <?= $this->Form->create($termsConditions) ?>
          <div class="box-body">
            <?= $this->Form->input('id', [
              'type' => 'hidden',
              'label' => false,
              'id' => null
            ]) ?>
            <?= $this->Form->input('body', [
              'label' => false,
              'required' => true,
              'id' => null,
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
