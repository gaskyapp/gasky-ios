<header class="main-header">
  <a href="<?= $this->Url->build(['controller' => 'Managers', 'action' => 'index']) ?>" class="logo">
    <span class="logo-mini">
      <?= $this->Html->image('gasky-icon.png', ['alt' => 'GASKY']) ?>
    </span>
    <span class="logo-lg">
      <?= $this->Html->image('gasky-icon.png', ['alt' => 'GASKY']) ?> <strong><?= __('ADMIN') ?></strong>
    </span>
  </a>

  <nav class="navbar navbar-static-top" role="navigation">
    <?= $this->Html->link(
      '<span class="sr-only">' . __('Toggle Navigation') . '</span>',
      '#',
      [
        'class' => 'sidebar-toggle',
        'data-toggle' => 'offcanvas',
        'role' => 'button',
        'escape' => false
    ]) ?>

    <div class="navbar-custom-menu">
      <ul class="nav navbar-nav">
        <li class="dropdown notifications-menu">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            <?= $activeManager['name'] ?>
          </a>
          <ul class="dropdown-menu">
            <li>
              <?= $this->Html->link(
                '<i class="fa fa-folder text-aqua"></i> ' . __('Update Information') . '</a>',
                ['controller' => 'Managers', 'action' => 'edit', $activeManager['id']],
                ['escape' => false]
              ) ?>
            </li>
            <li>
              <?= $this->Html->link(
                '<i class="fa fa-times text-red"></i> ' . __('Sign Out') . '</a>',
                ['controller' => 'Managers', 'action' => 'logout'],
                ['escape' => false]
              ) ?>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </nav>
</header>
