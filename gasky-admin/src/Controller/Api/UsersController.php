<?php
namespace App\Controller\Api;

use Cake\Event\Event;
use Cake\Network\Exception\UnauthorizedException;
use Cake\Utility\Security;
use Firebase\JWT\JWT;

class UsersController extends AppController {
  public function initialize() {
    parent::initialize();
    $this->Auth->allow(['add', 'token']);
  }
  
  public function add() {
    $this->Crud->on('afterSave', function(Event $event) {
      if ($event->subject->created) {
        // Create braintree account for user
        if (empty($event->subject->entity->payment_customer_id)) {
          $result = \Braintree\Customer::create($this->_formatBraintreeCustomerData($event->subject->entity));
          if ($result->success) {
            $user = $this->Users->get($event->subject->entity->id);
            $user->payment_customer_id = $result->customer->id;
            $this->Users->save($user);
          }
        }
        
        $this->set('data', [
          'id' => $event->subject->entity->id,
          'token' => JWT::encode(
            [
              'sub' => $event->subject->entity->id,
              'exp' => time() + 604800
            ],
            Security::salt()
          )
        ]);
        $this->Crud->action()->config('serialize.data', 'data');
      }
    });
    return $this->Crud->execute();
  }
  
  public function edit($user_id) {
    if ($user_id != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    $this->Crud->on('afterSave', function(Event $event) {
      if ($event->subject->success) {
        // Create/update braintree account for user
        if (empty($event->subject->entity->payment_customer_id)) {
          $result = \Braintree\Customer::create($this->_formatBraintreeCustomerData($event->subject->entity));
          if ($result->success) {
            $user = $this->Users->get($event->subject->entity->id);
            $user->payment_customer_id = $result->customer->id;
            $this->Users->save($user);
          }
        } else {
          \Braintree\Customer::update($event->subject->entity->payment_customer_id, $this->_formatBraintreeCustomerData($event->subject->entity));
        }
      }
      
      $this->Crud->action()->config('serialize.data', 'data');
    });
    $this->Crud->execute();
  }
  
  public function token() {
    $user = $this->Auth->identify();
    if (!$user) {
      throw new UnauthorizedException('Invalid username or password');
    }

    $this->set([
      'success' => true,
      'data' => [
        'id' => $user['id'],
        'token' => JWT::encode([
          'sub' => $user['id'],
          'exp' => time() + 604800
        ],
        Security::salt())
      ],
      '_serialize' => ['success', 'data']
    ]);
  }
  
  public function view($user_id) {
    if ($user_id != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    $this->Crud->on('beforeFind', function(\Cake\Event\Event $event) {
      $event->subject->query->contain(['PaymentMethods', 'Promos', 'Vehicles',
        'Orders' => function($q) {
          return $q->where(['status NOT IN' => ['completed', 'cancelled']]);
        }
      ]);
    });
    
    $this->Crud->on('afterFind', function(\Cake\Event\Event $event) {
      $event->subject->entity->payment_methods = $this->_assignPaymentMethodData($event->subject->entity->payment_methods);
      
      // Check if attached promo is still valid and remove it if not
      if (!empty($event->subject->entity->promo)) {
        $this->loadModel('Promos');
        $promo = $this->Promos->find()
          ->where(['code' => $event->subject->entity->promo->code])
          ->andWhere(['expires >' => new \DateTime()])
          ->andWhere(function($exp) {
            return $exp->or_(['max_uses IS' => null, 'uses < max_uses']);
          })
          ->first();

        if (empty($promo)) {
          $event->subject->entity->promo = null;
          $user = $this->Users->get($event->subject->entity->id);
          $user->promo_id = null;
          $this->Users->save($user);
        }
      }
    });
    
    $this->Crud->execute();
  }
  
  protected function _formatBraintreeCustomerData($user) {
    $customer_data = [
      'email' => $user->email,
      'phone' => $user->phone
    ];
    
    // Split name from single field into Braintree's first/last name field structure
    if ($user->name) {
      $name_parts = explode(' ', $user->name);
      $customer_data['lastName'] = array_pop($name_parts);
      $customer_data['firstName'] = implode(' ', $name_parts);
    }
        
    return $customer_data;
  }
}