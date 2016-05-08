<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Event\Event;

class LegalDocumentsController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
  }

  public function index() {
    $privacyPolicy = $this->LegalDocuments->get(1);
    $termsConditions = $this->LegalDocuments->get(2);

    if ($this->request->is('put')) {
      if ($this->request->data['id'] == 1) {
        $this->LegalDocuments->patchEntity($privacyPolicy, $this->request->data);
        if ($this->LegalDocuments->save($privacyPolicy)) {
          $this->Flash->success(__('Privacy policy updated.'));
        } else {
          $this->Flash->error(__('Privacy policy could not be updated.'));
        }
      } else {
        $this->LegalDocuments->patchEntity($termsConditions, $this->request->data);
        if ($this->LegalDocuments->save($termsConditions)) {
          $this->Flash->success(__('Terms & conditions updated.'));
        } else {
          $this->Flash->error(__('Terms & conditions could not be updated.'));
        }
      }
      unset($this->request->data['id']);
      unset($this->request->data['body']);
    }
    
    $this->set('privacyPolicy', $privacyPolicy);
    $this->set('termsConditions', $termsConditions);
  }
}
