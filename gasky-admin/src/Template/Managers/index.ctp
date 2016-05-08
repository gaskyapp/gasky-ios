<?php $this->assign('title', 'Gasky Manager Administration'); ?>
<?php $this->loadHelper('Form', ['templates' => 'generic_form']); ?>

<section class="content-header">
  <h1><?= __('Managers') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Administration') ?></li>
    <li class="active"><?= __('Managers') ?></li>
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
                <th><?= __('Username') ?></th>
                <th><?= __('Email') ?></th>
                <th><?= __('Role') ?></th>
                <th><?= __('Actions') ?></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($managers as $manager): ?>
                <tr>
                  <td><?= h($manager->name) ?></td>
                  <td><?= h($manager->username) ?></td>
                  <td><?= h($manager->email) ?></td>
                  <td><?= h($manager->role) ?></td>
                  <td>
                    <?= $this->Html->link(__('Edit'), ['action' => 'edit', $manager->id]) ?>
                    <?php if ($activeManager['id'] != $manager->id): ?>
                      - <?= $this->Form->postLink(__('Delete'), ['action' => 'delete', $manager->id], ['confirm' => __('Are you sure you want to delete {0}?', $manager->name)]) ?>
                    <?php endif; ?>
                  </td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      </div>

      <?= $this->Flash->render() ?>
      <div class="box box-warning">
        <div class="box-header with-border">
          <h3 class="box-title">Create New Manager Account</h3>
        </div>
        <?= $this->Form->create($newManager) ?>
          <div class="box-body">
            <?= $this->Form->input('name', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('username', [
              'required' => true,
              'class' => 'form-control',
            ]) ?>
            <?= $this->Form->input('password', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('email', [
              'required' => true,
              'class' => 'form-control'
            ]) ?>
            <?= $this->Form->input('role', [
              'class' => 'form-control',
              'options' => ['manager' => 'Manager', 'admin' => 'Admin']
            ]) ?>
          </div>
          <div class="box-footer">
            <?= $this->Form->button(__('Create Account'), [
              'class' => 'btn btn-warning'
            ]) ?>
          </div>
        <?= $this->Form->end() ?>
      </div>
    </div>
  </div>
</section>
