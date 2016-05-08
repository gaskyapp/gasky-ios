<aside class="main-sidebar">
  <section class="sidebar">
    <ul class="sidebar-menu">
      <li class="header"><?= __('Operations') ?></li>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'Orders', 'action' => 'index']) ?>">
          <i class="fa fa-circle-o"></i>
          <span><?= __('Open Orders') ?></span>
          <small class="label pull-right bg-green"><?= $openOrderCount ?></small>
        </a>
      </li>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'Orders', 'action' => 'completed']) ?>">
          <i class="fa fa-archive"></i>
          <span><?= __('Completed Orders') ?></span>
          <small class="label pull-right bg-gray"><?= $completedOrderCount ?></small>
        </a>
      </li>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'ServiceAreas', 'action' => 'index']) ?>">
          <i class="fa fa-globe"></i>
          <span><?= __('Service Areas') ?></span>
          <small class="label pull-right bg-blue"><?= $serviceAreaCount ?></small>
        </a>
      </li>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'ServicePricings', 'action' => 'index']) ?>">
          <i class="fa fa-usd"></i>
          <span><?= __('Pricing') ?></span>
          <small class="label pull-right bg-blue">$<?= number_format($regularPrice, 2) ?></small>
        </a>
      </li>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'Promos', 'action' => 'index']) ?>">
          <i class="fa fa-tag"></i>
          <span><?= __('Promos') ?></span>
          <small class="label pull-right bg-blue"><?= $promoCount ?></small>
        </a>
      </li>
      <li>
      <li class="header"><?= __('Customers') ?></li>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'Users', 'action' => 'index']) ?>">
          <i class="fa fa-users"></i>
          <span><?= __('Database') ?></span>
          <small class="label pull-right bg-blue"><?= $userCount ?></small>
        </a>
      </li>
      <li class="header"><?= __('Administration') ?></li>
      <?php if ($activeManager['role'] == 'admin'): ?>
        <li>
          <a href="<?= $this->Url->build(['controller' => 'Managers', 'action' => 'index']) ?>">
            <i class="fa fa-paw"></i>
            <span><?= __('Managers') ?></span>
            <small class="label pull-right bg-yellow"><?= $managerCount ?></small>
          </a>
        </li>
      <?php endif; ?>
      <li>
        <a href="<?= $this->Url->build(['controller' => 'LegalDocuments', 'action' => 'index']) ?>">
          <i class="fa fa-gavel"></i>
          <span><?= __('Legal Information') ?></span>
        </a>
      </li>
    </ul>
  </section>
</aside>
