<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class Vehicle extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
  
  protected $_hidden = ['id', 'created', 'modified', 'user_id'];
}
