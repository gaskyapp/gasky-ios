<?php $this->assign('title', 'Gasky Login'); ?>
<?php $this->loadHelper('Form', ['templates' => 'login_form']); ?>

<div class="login-box">
  <div class="login-logo">
    <?= $this->Html->image('gasky.png', [
      'alt' => 'Gasky',
      'class' => 'center-block img-responsive',
      'url' => 'http://www.gasky.co'
    ]) ?>
  </div>

  <div class="login-box-body">
    <?= $this->Flash->render() ?>
    <?= $this->Form->create() ?>
      <?= $this->Form->input('username', [
        'label' => false,
        'placeholder' => 'Username',
        'required' => true,
        'class' => 'form-control',
        'templateVars' => ['icon' => 'glyphicon-user']
      ]) ?>
      <?= $this->Form->input('password', [
        'label' => false,
        'placeholder' => 'Password',
        'required' => true,
        'class' => 'form-control',
        'templateVars' => ['icon' => 'glyphicon-lock']
      ]) ?>
      <div class="row">
        <div class="col-xs-4 col-xs-offset-8">
          <?= $this->Form->button(__('Sign In'), [
            'class' => 'btn btn-primary btn-block btn-flat'
          ]) ?>
        </div>
      </div>
    <?= $this->Form->end() ?>
  </div>

  <h6 class=" text-center">&copy; <?= __('2016 Gasky, LLC') ?></h6>
</div>
