<?php
namespace App\Model\Table;

use Cake\Event\Event;
use Cake\ORM\Table;
use Cake\Validation\Validator;

class PaymentMethodsTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
    $this->belongsTo('Users');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('token')
      ->notEmpty('token');
  }
}
