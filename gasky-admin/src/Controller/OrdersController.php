<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Event\Event;
use Cake\I18n\Time;

class OrdersController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
  }

  public function index($type = 'open') {
    $orders = $this->Orders->find()
      ->select([
        'Orders.id',
        'Orders.delivery_date',
        'Orders.delivery_time',
        'Orders.delivering_at',
        'Orders.delivered_at',
        'Orders.finalized_at',
        'Orders.latitude',
        'Orders.longitude',
        'Orders.paid',
        'Users.id',
        'Users.name'
      ])
      ->where(['status NOT IN' => ['completed', 'cancelled']])
      ->contain(['Users']);      
    
    $this->set('orders', $orders);
  }
  
  public function delivering($orderId) {
    $this->request->allowMethod('post');
    
    $order = $this->Orders->get($orderId);
    $order->delivering_at = Time::now();
    $this->Orders->save($order);
    
    return $this->redirect($this->referer());
  }
  
  public function delivered($orderId) {
    $this->request->allowMethod('post');
    
    $order = $this->Orders->get($orderId);
    $order->delivered_at = Time::now();
    $this->Orders->save($order);
    
    return $this->redirect($this->referer());
  }
  
  public function finalize($orderId) {
    $this->request->allowMethod('put');
    
    $order = $this->Orders->find('all')
      ->where(['Orders.id' => $orderId])
      ->contain([
        'Images',
        'Promos',
        'Users.PaymentMethods' => function($q) {
          return $q->where(['default_payment' => 1]);
        }
      ])
      ->first();
    
    $order->finalized_at = Time::now();
    $order->delivery_fee = 5.00;
    $this->Orders->patchEntity($order, $this->request->data, [
      'associated' => ['Images']
    ]);
    if (!$this->Orders->save($order)) {
      $this->Flash->error(__('Order could not be settled. Check that all of the information is complete and accurate and try again.'));
    }
    
    return $this->redirect($this->referer());
  }
  
  public function retryPayment($orderId) {
    $order = $this->Orders->find('all')
      ->where(['Orders.id' => $orderId])
      ->contain(['Users.PaymentMethods' => function($q) {
        return $q->where(['default_payment' => 1]);
      }])
      ->first();
    
    // Dirty the paid value to force a save
    $order->dirty('paid', true);
    if (!$this->Orders->save($order)) {
      $this->Flash->error(__('Unable to retry payment.'));
    }
    
    return $this->redirect($this->referer());
  }
  
  public function completed() {
    $orders = $this->Orders->find()
      ->select([
        'Orders.id',
        'Orders.delivery_date',
        'Orders.total',
        'Orders.status',
        'Users.id',
        'Users.name'
      ])
      ->where(['status IN' => ['completed', 'cancelled']])
      ->contain(['Users']);
    
    $this->set('orders', $orders);
  }
  
  public function view($orderId) {
    $order = $this->Orders->find()
      ->where([
        'Orders.id' => $orderId,
      ])
      ->contain(['Images', 'OrderRatings', 'Promos', 'Users.Vehicles'])
      ->first();
    
    $this->set('order', $order);
    
    if (empty($order->delivering_at)) {
      $this->render('view_delivering_trigger');
    } else if (empty($order->delivered_at)) {
      $this->render('view_delivered_trigger');
    } else if (empty($order->finalized_at)) {
      $this->render('view_finalize_form');
    } else if (empty($order->completed_at) && $order->paid == 0) {
      $this->render('view_payment_failure_form');
    } else {
      $this->render('view_order_summary');
    }
  }
}
