<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class ServicePricing extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
  
  protected $_hidden = ['id', 'modified'];
}
