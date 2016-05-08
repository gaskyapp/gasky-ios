<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class ManagersTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('username', 'create')
      ->notEmpty('username', 'A username is required.')
      ->add('username', 'unique', [
        'rule' => 'validateUnique',
        'provider' => 'table',
        'message' => 'Username is not available.'
      ])
      ->requirePresence('password', 'create')
      ->notEmpty('password', 'A password is required.')
      ->requirePresence('name', 'create')
      ->notEmpty('name', 'A name is required', 'create')
      ->requirePresence('email', 'create')
      ->notEmpty('email', 'An email is required.')
      ->add('email', 'validFormat', [
        'rule' => 'email',
        'message' => 'A valid email is required.',
      ])
      ->add('email', 'unique', [
        'rule' => 'validateUnique',
        'provider' => 'table',
        'message' => 'Email address belongs to an existing manager.'
      ])
      ->requirePresence('role', 'create')
      ->notEmpty('role', 'A role is required.')
      ->add('role', 'inList', [
        'rule' => ['inList', ['admin', 'manager']],
        'message' => 'A valid role is required.'
      ]);
  }
}
