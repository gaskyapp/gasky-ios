<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Event\Event;

class PromosController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
  }

  public function index() {
    $this->set('promos', $this->Promos->find('all')->formatResults(function($results) {
      return $results->map(function($row) {
        if ($row['max_uses'] == null) {
          $row['max_uses'] = 'Unlimited';
        }
        
        return $row;
      });
    }));

    $newPromo = $this->Promos->newEntity();
    if ($this->request->is('post')) {
      if (empty($this->request->data['max_uses'])) {
        $this->request->data['max_uses'] = null;
      }
      $newPromo = $this->Promos->patchEntity($newPromo, $this->request->data);      
      if ($this->Promos->save($newPromo)) {
        $this->Flash->success(__('Promo created.'));
        $newPromo = $this->Promos->newEntity();
        unset($this->request->data['code']);
        unset($this->request->data['percent_off']);
        unset($this->request->data['dollar_amount_off']);
        unset($this->request->data['expires']);
        unset($this->request->data['max_uses']);
      } else {
        $this->Flash->error(__('Promo could not be created. See the errors below.'));
      }
    }
    $this->set('newPromo', $newPromo);
  }

  public function delete($promoId) {
    $this->request->allowMethod('post');

    $promo = $this->Promos->get($promoId);
    $result = $this->Promos->delete($promo);

    return $this->redirect($this->referer());
  }
}
