<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class ServicePricingsTable extends Table {
  public function initialize(array $config) {
    $this->table('service_pricing');
    $this->addBehavior('Timestamp');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('name', 'create')
      ->notEmpty('name', 'A name is required.')
      ->add('name', 'unique', [
        'rule' => 'validateUnique',
        'provider' => 'table',
        'message' => 'A unique name is required.'
      ])
      ->requirePresence('cost')
      ->notEmpty('cost', 'A cost is required.')
      ->add('cost', 'isMonetary', [
        'rule' => ['decimal', 2],
        'message' => 'A cost to 2 decimal places is required.'
      ]);
  }
}
