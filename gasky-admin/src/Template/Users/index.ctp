<?php $this->assign('title', 'Gasky Customer Database'); ?>

<section class="content-header">
  <h1><?= __('Customer Database') ?></h1>

  <ol class="breadcrumb">
    <li><?= __('Customers') ?></li>
    <li class="active"><?= __('Database') ?></li>
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
                <th><?= __('Email') ?></th>
                <th><?= __('Phone') ?></th>
                <th><?= __('Created') ?></th>
                <th><?= __('Actions') ?></th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($users as $user): ?>
                <tr>
                  <td><?= h($user->name) ?></td>
                  <td><?= h($user->email) ?></td>
                  <td><?= h($user->phone) ?></td>
                  <td><?= $this->Time->format($user->created_at, 'M/dd/yyyy', null, 'America/New_York') ?></td>
                  <td><?= $this->Html->link(__('View'), ['action' => 'view', $user->id]) ?></td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</section>
