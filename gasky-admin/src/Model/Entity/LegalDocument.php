<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class LegalDocument extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
}
