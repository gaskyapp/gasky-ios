<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Datasource\ConnectionManager;
use Cake\Event\Event;

class UsersController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
  }

  public function index() {
    $this->set('users', $this->Users->find('all'));
  }

  public function view($userId) {
    $user = $this->Users->find()
      ->where(['Users.id' => $userId])
      ->contain(['Orders', 'Vehicles', 'PaymentMethods' => function($q) {
        return $q->where(['default_payment' => 1]);
      }])
      ->first();
    $this->set('user', $user);
  }
}
