<?php
namespace App\Controller\Api;

use Cake\Event\Event;
use Cake\Network\Exception\HttpException;
use Cake\Network\Exception\NotFoundException;
use Cake\Network\Exception\UnauthorizedException;
use Cake\Utility\Security;
use Firebase\JWT\JWT;

class PaymentMethodsController extends AppController {
  public function initialize() {
    parent::initialize();
  }
  
  public function add() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    if (empty($this->request->data['payment_method_nonce'])) {
      throw new HttpException('Missing required payment_method_nonce', 422);
    }
    
    if (empty($this->request->data['zip'])) {
      throw new HttpException('Missing required zip', 422);
    }
    
    $this->loadModel('Users');
    $user = $this->Users->get($this->request->params['user_id']);
    
    if (empty($user->payment_customer_id)) {
      throw new HttpException('User missing payment_customer_id', 422);
    }
    
    $result = \Braintree\PaymentMethod::create([
      'customerId' => $user->payment_customer_id,
      'paymentMethodNonce' => $this->request->data['payment_method_nonce'],
      'billingAddress' => [
        'postalCode' => $this->request->data['zip']
      ],
      'options' => [
        'makeDefault' => true,
        'failOnDuplicatePaymentMethod' => false,
        'verifyCard' => true
      ]
    ]);
    
    if ($result->success) {      
      $new_payment_method = $this->PaymentMethods->newEntity();
      $new_payment_method->token = $result->paymentMethod->token;
      $new_payment_method->user_id = $this->request->params['user_id'];
      $this->PaymentMethods->save($new_payment_method);
      
      $new_payment_method->card_type = $result->paymentMethod->cardType;
      $new_payment_method->default = ($result->paymentMethod->default ? true : false);
      $new_payment_method->digits = $result->paymentMethod->last4;
      $new_payment_method->expiration_date = $result->paymentMethod->expirationDate;
      $new_payment_method->expired = ($result->paymentMethod->expired ? true : false);
      $new_payment_method->zip = $result->paymentMethod->billingAddress->postalCode;
      unset($new_payment_method->user_id);
      
      $this->set([
        'success' => true,
        'data' => $new_payment_method,
        '_serialize' => ['success', 'data']
      ]);
    } else {
      throw new HttpException('Invalid payment method', 422);
    }
  }

  public function delete() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    // Don't allow deletion of last remaining payment method of the user has an open order
    $this->loadModel('Orders');
    $user_orders = $this->Orders->find()
      ->where(['user_id' => $this->request->params['user_id']])
      ->andWhere(['status NOT IN' => ['completed', 'cancelled']]);
    if ($user_orders->count() > 0) {
      $user_payment_methods = $this->PaymentMethods->find()
        ->where(['user_id' => $this->request->params['user_id']]);
      if ($user_payment_methods->count() < 2) {
        throw new HttpException('Can not delete last payment method while an order is open', 409);
      }
    }
    
    $this->Crud->on('beforeFind', function(\Cake\Event\Event $event) {
      $event->subject->query->where(['user_id' => $this->request->params['user_id']]);
    });
    
    $this->Crud->on('afterDelete', function(\Cake\Event\Event $event) {
      \Braintree\PaymentMethod::delete($event->subject->entity->token);
    });
    $this->Crud->execute();
  }
  
  public function index() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    $user_payment_methods = $this->PaymentMethods->find()
      ->where(['user_id' => $this->request->params['user_id']])
      ->all();
    
    foreach ($user_payment_methods as $payment_method) {
      $payment_method = $this->_assignPaymentMethodData($payment_method);
    }
    
    $this->set([
      'success' => true,
      'data' => $user_payment_methods,
      '_serialize' => ['success', 'data']
    ]);
  }
  
  public function primary() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    if (empty($this->request->data['id'])) {
      throw new HttpException('Missing required id', 422);
    }
    
    $payment_method = $this->PaymentMethods->find()
      ->where(['id' => $this->request->data['id']])
      ->andWhere(['user_id' => $this->request->params['user_id']])
      ->first();
      
    if (empty($payment_method)) {
      throw new NotFoundException();
    }
        
    \Braintree\PaymentMethod::update($payment_method->token, [
      'options' => ['makeDefault' => true]
    ]);
    
    $this->set([
      'success' => true,
      'data' => [],
      '_serialize' => ['success', 'data']
    ]);
  }
  
  public function view() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    $this->Crud->on('afterFind', function(\Cake\Event\Event $event) {
      $event->subject->entity = $this->_assignPaymentMethodData($event->subject->entity);
    });
    
    $this->Crud->execute();
  }
}