<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class VehiclesTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
    $this->belongsTo('Users');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('plates', 'create')
      ->notEmpty('plates')
      ->requirePresence('make', 'create')
      ->notEmpty('make')
      ->requirePresence('model', 'create')
      ->notEmpty('model')
      ->requirePresence('year', 'create')
      ->notEmpty('year')
      ->add('year', [
        'numeric' => [
          'rule' => 'numeric',
          'message' => 'Year must be numeric.'
        ]
      ])
      ->requirePresence('color', 'create')
      ->notEmpty('color');
  }
}
