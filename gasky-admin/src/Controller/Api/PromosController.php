<?php
namespace App\Controller\Api;

use Cake\Event\Event;
use Cake\Network\Exception\NotFoundException;
use Cake\Network\Exception\UnauthorizedException;

class PromosController extends AppController {
  public function initialize() {
    parent::initialize();
  }
  
  public function add() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    $promo = $this->Promos->find()
      ->where(['code' => $this->request->data['code']])
      ->andWhere(['expires >' => new \DateTime()])
      ->andWhere(function($exp) {
        return $exp->or_(['max_uses IS' => null, 'uses < max_uses']);
      })
      ->first();
      
    if (empty($promo)) {
      throw new NotFoundException('Promo not found.');
    }
    
    $this->loadModel('Users');
    $user = $this->Users->get($this->request->params['user_id']);
    $user->promo_id = $promo->id;
    $this->Users->save($user);
    
    $this->set([
      'success' => true,
      'data' => $promo,
      '_serialize' => ['success', 'data']
    ]);
  }
  
  public function remove() {
    if ($this->request->params['user_id'] != $this->Auth->user('id')) {
      throw new UnauthorizedException();
    }
    
    $this->loadModel('Users');
    $user = $this->Users->get($this->request->params['user_id']);
    $user->promo_id = null;
    $this->Users->save($user);
    
    $this->set([
      'success' => true,
      'data' => null,
      '_serialize' => ['success', 'data']
    ]);
  }
  
  public function view() {
    $this->Crud->on('beforeFind', function(\Cake\Event\Event $event) {
      $event->subject()->query->where(['code' => $event->subject->id], [], true);
      $event->subject()->query->andWhere(['expires >' => new \DateTime()]);
      $event->subject()->query->andWhere(function($exp) {
        return $exp->or_(['max_uses IS' => null, 'uses < max_uses']);
      });
    });
    $this->Crud->execute();
  }
}