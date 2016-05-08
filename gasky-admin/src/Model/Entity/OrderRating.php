<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class OrderRating extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
}
