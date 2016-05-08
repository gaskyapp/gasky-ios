<?php
namespace App\Model\Table;

use Cake\Event\Event;
use Cake\I18n\Time;
use Cake\ORM\Entity;
use Cake\ORM\Table;
use Cake\Validation\Validator;

class OrdersTable extends Table {
  public function initialize(array $config) {
    $this->belongsTo('Users');
    $this->belongsTo('Promos');
    $this->hasOne('Images', [
      'foreignKey' => 'entity_id',
      'dependent' => true
    ]);
    $this->hasOne('OrderRatings', [
      'dependent' => true
    ]);
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->add('delivering_at', 'dateTime', [
        'rule' => 'dateTime',
        'message' => 'Delivering at time is invalid.'
      ])
      ->add('delivered_at', 'dateTime', [
        'rule' => 'dateTime',
        'message' => 'Delivering at time is invalid.'
      ])
      ->add('completed_at', 'dateTime', [
        'rule' => 'dateTime',
        'message' => 'Delivering at time is invalid.'
      ])
      ->add('discount', 'decimal', [
        'rule' => ['decimal', 2],
        'message' => 'A discount amount to 2 decimal places is required.'
      ])
      ->add('total', 'decimal', [
        'rule' => ['decimal', 2],
        'message' => 'A total dollar amount to 2 decimal places is required.'
      ])
      ->add('price_per_gallon', 'decimal', [
        'rule' => ['decimal', 2],
        'message' => 'A price per gallon to 2 decimal places is required.'
      ])
      ->add('gallons', 'range', [
        'rule' => ['range', 0, 999999999],
        'message' => 'Number of gallons must be positive.'
      ])
      ->add('gas_total', 'decimal', [
        'rule' => ['decimal', 2],
        'message' => 'A gas total amount to 2 decimal places is required.'
      ])
      ->add('delivery_fee', 'decimal', [
        'rule' => ['decimal', 2],
        'message' => 'A delivery fee amount to 2 decimal places is required.'
      ]);
  }
  
  public function beforeSave(Event $event, Entity $entity, \ArrayObject $options) {
    // Run calculations to determine gas total, discount amount, and total
    if (!empty($entity->finalized_at) && empty($entity->total)) {
      $entity->gas_total = round($entity->price_per_gallon * $entity->gallons, 2);
      
      if (!empty($entity->promo)) {
        if ($entity->promo->percent_off > 0) {
          $entity->discount = ($entity->gas_total + $entity->delivery_fee) / 100 * $entity->promo->percent_off;
        } else {
          $entity->discount = $entity->promo->dollar_amount_off;
        }
      } else {
        $entity->discount = 0;
      }
      
      $entity->total = $entity->gas_total + $entity->delivery_fee - $entity->discount;
    }
    
    // Attempt payment    
    if (!empty($entity->total) && !$entity->paid && !empty($entity->user->payment_methods)) {
      $result = \Braintree\Transaction::sale([
        'amount' => $entity->total,
        'orderId' => $entity->id,
        'paymentMethodToken' => $entity->user->payment_methods[0]->token,
        'options' => ['submitForSettlement' => true]
      ]);
      
      if ($result->success) {
        $entity->paid = 1;
        $entity->payment_at = Time::now();
        $entity->status = 'feedback';
      }
    }
  }

  public function boundaryMinimumCheck($value, $context) {
    return substr_count($value, ',') >= 5;
  }
}
