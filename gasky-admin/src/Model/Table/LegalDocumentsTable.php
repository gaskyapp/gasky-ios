<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class LegalDocumentsTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('title', 'create')
      ->notEmpty('title', 'A title is required.')
      ->add('title', 'unique', [
        'rule' => 'validateUnique',
        'provider' => 'table',
        'message' => 'A unique title is required.'
      ])
      ->requirePresence('body')
      ->notEmpty('body', 'Content is required.');
  }
}
