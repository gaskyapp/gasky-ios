<?php
namespace App\Controller;

use App\Controller\AppController;
use Cake\Event\Event;

class ManagersController extends AppController {
  public function beforeFilter(Event $event) {
    parent::beforeFilter($event);
    // The login action is not explicitly allowed here as the action is managed
    // and handled automatically via AuthComponent.
    $this->Auth->allow(['logout']);
  }

  public function index() {
    $this->set('managers', $this->Managers->find('all'));

    $newManager = $this->Managers->newEntity();
    if ($this->request->is('post')) {
      $newManager = $this->Managers->patchEntity($newManager, $this->request->data);
      if ($this->Managers->save($newManager)) {
        $this->Flash->success(__('Manager account created.'));
        $newManager = $this->Managers->newEntity();
        unset($this->request->data['name']);
        unset($this->request->data['username']);
        unset($this->request->data['password']);
        unset($this->request->data['email']);
        unset($this->request->data['role']);
      } else {
        $this->Flash->error(__('Manager account could not be created. See the errors below.'));
      }
    }
    $this->set('newManager', $newManager);
  }

  public function edit($managerId) {
    // Protected action: admins or self edits only
    $activeManager = $activeManager = $this->request->session()->read('Auth.User');
    if ($activeManager['role'] != 'admin' && $activeManager['id'] != $managerId) {
      return $this->redirect($this->referer());
    }

    $manager = $this->Managers->get($managerId);
    if ($this->request->is('put')) {
      // Unset username and role fields, these are not editable after creation
      unset($this->request->data['username']);
      unset($this->request->data['role']);
      // Unset password data if the field was left blank
      if (empty($this->request->data['password'])) {
        unset($this->request->data['password']);
      }
      $this->Managers->patchEntity($manager, $this->request->data);
      if ($this->Managers->save($manager)) {
        // Update auth user if own account was updated
        if ($activeManager['id'] === $manager->id) {
          $data = $manager->toArray();
          $this->Auth->setUser($data);
        }
        $this->Flash->success(__('Account updated.'));
      } else {
        $this->Flash->error(__('Account could not be updated. See the errors below.'));
      }
    }

    $this->set('manager', $manager);
  }

  public function delete($managerId) {
    $this->request->allowMethod('post');

    $activeManager = $activeManager = $this->request->session()->read('Auth.User');
    if ($activeManager['role'] != 'admin') {
      return $this->redirect($this->referer());
    }

    $manager = $this->Managers->get($managerId);
    $result = $this->Managers->delete($manager);

    return $this->redirect($this->referer());
  }

  public function login() {
    $this->viewBuilder()->layout('login');

    if ($this->request->is('post')) {
      $manager = $this->Auth->identify();
      if ($manager) {
        $this->Auth->setUser($manager);
        return $this->redirect($this->Auth->redirectUrl());
      }
      $this->Flash->error(__('Invalid username or password, try again.'));
    }
  }

  public function logout() {
    return $this->redirect($this->Auth->logout());
  }
}
