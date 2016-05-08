<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Event\Event;

class ServiceAreasController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
  }

  public function index() {
    $this->set('serviceAreas', $this->ServiceAreas->find('all')->formatResults(function($results) {
      return $results->map(function($row) {
        $bounds = [];
        $pieces = explode(',', $row['bounds']);

        for($i = 0; $i < count($pieces); $i+=2) {
          $bounds[] = [$pieces[$i], $pieces[$i+1]];
        }
        $row['bounds'] = $bounds;

        return $row;
      });
    }));

    $newServiceArea = $this->ServiceAreas->newEntity();
    if($this->request->is('post')) {
      $boundString = '';
      for($i = 0; $i < count($this->request->data['lat']); $i++) {
        if(is_numeric($this->request->data['lat'][$i]) && is_numeric($this->request->data['lng'][$i])) {
          $boundString .= $this->request->data['lat'][$i] . ',' . $this->request->data['lng'][$i] . ',';
        }
      }
      $boundString = rtrim($boundString, ',');
      $this->request->data['bounds'] = $boundString;

      $newServiceArea = $this->ServiceAreas->patchEntity($newServiceArea, $this->request->data);
      if($this->ServiceAreas->save($newServiceArea)) {
        $this->Flash->success(__('Service area created.'));
        $newServiceArea = $this->ServiceAreas->newEntity();
        unset($this->request->data['name']);
        unset($this->request->data['bounds']);
        unset($this->request->data['lat']);
        unset($this->request->data['lng']);
      } else {
        $this->Flash->error(__('Service area could not be created. See the errors below.'));
      }
    }
    $this->set('newServiceArea', $newServiceArea);
  }

  public function edit($serviceAreaId) {
    $serviceArea = $this->ServiceAreas->get($serviceAreaId);
    $serviceArea->lat = [];
    $serviceArea->lng = [];
    $pieces = explode(',', $serviceArea->bounds);

    for ($i = 0; $i < count($pieces); $i+=2) {
      $serviceArea->lat[] = $pieces[$i];
      $serviceArea->lng[] = $pieces[$i+1];
    }

    if ($this->request->is('put')) {
      $boundString = '';
      for($i = 0; $i < count($this->request->data['lat']); $i++) {
        if(is_numeric($this->request->data['lat'][$i]) && is_numeric($this->request->data['lng'][$i])) {
          $boundString .= $this->request->data['lat'][$i] . ',' . $this->request->data['lng'][$i] . ',';
        }
      }
      $boundString = rtrim($boundString, ',');
      $this->request->data['bounds'] = $boundString;

      $this->ServiceAreas->patchEntity($serviceArea, $this->request->data);
      if ($this->ServiceAreas->save($serviceArea)) {
        $this->Flash->success(__('Service area updated.'));
      } else {
        $this->Flash->error(__('Service area could not be updated. See the errors below.'));
      }
    }
    $this->set('serviceArea', $serviceArea);
  }

  public function delete($serviceAreaId) {
    $this->request->allowMethod('post');

    $serviceArea = $this->ServiceAreas->get($serviceAreaId);
    $result = $this->ServiceAreas->delete($serviceArea);

    return $this->redirect($this->referer());
  }
}
