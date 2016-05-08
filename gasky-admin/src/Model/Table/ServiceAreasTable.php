<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class ServiceAreasTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('name')
      ->notEmpty('name', 'A name is required.')
      ->add('name', 'unique', [
        'rule' => 'validateUnique',
        'provider' => 'table',
        'message' => 'A unique name is required.'
      ])
      ->requirePresence('bounds')
      ->notEmpty('bounds', 'Area bounds are required.')
      ->add('bounds', [
        'custom' => [
          'rule' => [$this, 'boundaryMinimumCheck'],
          'message' => 'A minimum of 3 properly formed coordinates are required.'
        ]]);
  }

  public function boundaryMinimumCheck($value, $context) {
    return substr_count($value, ',') >= 5;
  }
}
