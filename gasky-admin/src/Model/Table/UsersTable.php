<?php
namespace App\Model\Table;

use Cake\Localized\Validation\UsValidation;
use Cake\ORM\Table;
use Cake\Validation\Validator;

class UsersTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
    $this->hasOne('Vehicles', ['dependent' => true]);
    $this->hasMany('Orders');
    $this->hasMany('OrderRatings');
    $this->hasMany('PaymentMethods', ['dependent' => true]);
    $this->belongsTo('Promos');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->provider('us', UsValidation::class)
      ->requirePresence('email', 'create')
      ->notEmpty('email')
      ->add('email', [
        'email' => [
          'rule' => 'email',
          'message' => 'Valid email address required.'
        ],
        'validateUnique' => [
          'rule' => 'validateUnique',
          'provider' => 'table',
          'message' => 'Email address already registered.'
        ]
      ])
      ->requirePresence('password', 'create')
      ->notEmpty('password')
      ->add('password', [
        'lengthBetween' => [
          'rule' => ['lengthBetween', 8, 100],
          'message' => 'Password must be at least 8 characters.'
        ]
      ])
      ->notEmpty('name')
      ->add('name', [
        'custom' => [
          'rule' => [$this, 'twoWordMinimum'],
          'message' => 'First and last name required.'
        ]])
      ->notEmpty('phone')
      ->add('phone', [
        'validPhone' => [
          'rule' => 'phone',
          'provider' => 'us',
          'message' => 'Invalid phone number.'
        ]
      ]);
  }
  
  public function twoWordMinimum($value, $context) {
    return str_word_count($value) > 1;
  }
}
