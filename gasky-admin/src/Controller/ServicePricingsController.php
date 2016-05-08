<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Event\Event;

class ServicePricingsController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
  }

  public function index() {
    $regularGas = $this->ServicePricings->get(3);

    if ($this->request->is('put')) {
      $this->ServicePricings->patchEntity($regularGas, $this->request->data);
      if ($this->ServicePricings->save($regularGas)) {
        $this->Flash->success(__('Gas price updated.'));
      } else {
        $this->Flash->error(__('Gas price could not be updated.'));
      }
    }
    $this->set('regularGas', $regularGas);
  }
}
