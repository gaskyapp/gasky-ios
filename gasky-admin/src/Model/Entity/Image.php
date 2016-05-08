<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class Image extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
}
