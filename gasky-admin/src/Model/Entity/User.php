<?php
namespace App\Model\Entity;

use Cake\Auth\DefaultPasswordHasher;
use Cake\ORM\Entity;

class User extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false,
    'promo' => false,
    'orders' => false,
    'payment_methods' => false
  ];
  
  protected $_hidden = ['password', 'payment_customer_id', 'promo_id', 'created', 'modified'];
  
  protected function _setPassword($password) {
    return (new DefaultPasswordHasher)->hash($password);
  }
}
