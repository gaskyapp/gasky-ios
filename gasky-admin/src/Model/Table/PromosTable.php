<?php
namespace App\Model\Table;

use Cake\Datasource\ConnectionManager;
use Cake\Event\Event;
use Cake\I18n\Time;
use Cake\ORM\Entity;
use Cake\ORM\Table;
use Cake\Validation\Validator;

class PromosTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
    $this->hasMany('Users');
  }

  public function validationDefault(Validator $validator) {
    return $validator
      ->requirePresence('code', 'create')
      ->notEmpty('code', 'A code is required.', 'create')
      ->add('code', 'unique', [
        'rule' => 'validateUnique',
        'provider' => 'table',
        'message' => 'A unique code is required.'
      ])
      ->add('code', 'valid', [
        'rule' => 'alphaNumeric',
        'message' => 'Code must be alphanumeric.'
      ])
      ->requirePresence('expires', 'create')
      ->notEmpty('expires', 'An expiration date is required.', 'create')
      ->add('expires', 'valid', [
        'rule' => ['date', 'mdy'],
        'message' => 'A valid expiration date is required.'
      ])
      ->requirePresence('percent_off', 'create')
      ->notEmpty('percent_off', 'A discount percentage is required.', 'create')
      ->add('percent_off', 'valid', [
        'rule' => 'numeric',
        'message' => 'Discount percentage must be numeric.'
      ])
      ->add('percent_off', 'valid', [
        'rule' => ['range', 0, 100],
        'message' => 'Discount percentage must be between 0 and 100.'
      ])
      ->add('percent_off', [
        'combination' => [
          'rule' => [$this, 'checkDollarAgainstPercent'],
          'message' => 'A discount percentage or amount must be given.'
        ]])
      ->add('percent_off', [
        'presence' => [
          'rule' => [$this, 'checkSingleDiscountValue'],
          'message' => 'A discount percentage and discount amount can not be used in combination.'
        ]])
      ->requirePresence('dollar_amount_off', 'create')
      ->notEmpty('dollar_amount_off', 'A dollar amount is required.', 'create')
      ->add('dollar_amount_off', 'isMonetary', [
        'rule' => ['decimal', 2],
        'message' => 'A dollar amount to 2 decimal places is required.'
      ])
      ->add('dollar_amount_off', 'valid', [
        'rule' => ['range', 0, 10000000],
        'message' => 'Dollar amount must be positive.'
      ])
      ->add('dollar_amount_off', [
        'presence' => [
          'rule' => [$this, 'checkPercentAgainstDollar'],
          'message' => 'A discount percentage or amount must be given.'
        ]])
      ->add('dollar_amount_off', [
        'combination' => [
          'rule' => [$this, 'checkSingleDiscountValue'],
          'message' => 'A discount percentage and discount amount can not be used in combination.'
        ]]);
  }
  
  public function beforeMarshal(Event $event, \ArrayObject $data, \ArrayObject $options) {
    if (isset($data['expires']) && is_string($data['expires'])) {
      $dateParts = explode('/', $data['expires']);
      $data['expires'] = Time::parseDateTime($dateParts[2] . '-' . $dateParts[0] . '-' . $dateParts[1] . ' 23:59:59 America/New_York', 'yyyy-MM-dd HH:mm:ss VV');
    }
  }
  
  public function afterDelete(Event $event, Entity $entity, \ArrayObject $options) {
    $connection = ConnectionManager::get('default');
    $connection->delete('promo_usage', ['promo_id' => $entity->id]);
  }

  public function checkPercentAgainstDollar($value, $context) {
    if ($context['data']['percent_off'] <= 0 && $value <= 0) {
      return false;
    }
    return true;
  }
  
  public function checkDollarAgainstPercent($value, $context) {
    if ($context['data']['dollar_amount_off'] <= 0 && $value <= 0) {
      return false;
    }
    return true;
  }
  
  public function checkSingleDiscountValue($value, $context) {
    return !($context['data']['percent_off'] > 0 && $context['data']['dollar_amount_off'] > 0);
  }
}
