<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class Promo extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
  
  protected $_hidden = ['id', 'uses', 'max_uses', 'created'];
}
