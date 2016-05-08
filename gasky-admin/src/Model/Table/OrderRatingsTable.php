<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class OrderRatingsTable extends Table {
  public function initialize(array $config) {
    $this->belongsTo('Users');
    $this->belongsTo('Orders');
  }

  public function validationDefault(Validator $validator) {
    return $validator;
  }
}
