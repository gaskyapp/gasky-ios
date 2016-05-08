<?php
/**
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link      http://cakephp.org CakePHP(tm) Project
 * @since     0.2.9
 * @license   http://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace App\Controller;

use Cake\Core\Configure;
use Cake\Controller\Controller;
use Cake\Event\Event;

/**
 * Application Controller
 *
 * Add your application-wide methods in the class below, your controllers
 * will inherit them.
 *
 * @link http://book.cakephp.org/3.0/en/controllers.html#the-app-controller
 */
class AppController extends Controller
{

    /**
     * Initialization hook method.
     *
     * Use this method to add common initialization code like loading components.
     *
     * e.g. `$this->loadComponent('Security');`
     *
     * @return void
     */
    public function initialize()
    {
        parent::initialize();

        $this->loadComponent('RequestHandler');
        $this->loadComponent('Flash');
        $this->loadComponent('Auth', [
            'authenticate' => [
                'Form' => ['userModel' => 'Managers']
            ],
            'loginAction' => [
                'controller' => 'Managers',
                'action' => 'login'
            ],
            'loginRedirect' => [
                'controller' => 'Orders',
                'action' => 'index'
            ],
            'logoutRedirect' => [
                'controller' => 'Managers',
                'action' => 'login'
            ]
        ]);
        
        \Braintree\Configuration::environment(Configure::read('Braintree.environment'));
        \Braintree\Configuration::merchantId(Configure::read('Braintree.merchantId'));
        \Braintree\Configuration::publicKey(Configure::read('Braintree.publicKey'));
        \Braintree\Configuration::privateKey(Configure::read('Braintree.privateKey'));
    }

    /**
     * Before filter callback.
     *
     * @param \Cake\Event\Event $event The beforeFilter event.
     * @return void
     */
    public function beforeFilter(Event $event)
    {
        $this->Auth->allow([]);
    }

    /**
     * Before render callback.
     *
     * @param \Cake\Event\Event $event The beforeRender event.
     * @return void
     */
    public function beforeRender(Event $event)
    {
        // Set current logged in manager session data for use in templates
        $activeManager = $this->request->session()->read('Auth.User');
        $this->set('activeManager', $activeManager);

        // Set overview information for use in templates, perhaps this should be moved elsewhere eventually?
        // Open order count
        $this->loadModel('Orders');
        $queryOpenOrders = $this->Orders->find('all')
            ->where(['status NOT IN' => ['completed', 'cancelled']]);
        $this->set('openOrderCount', $queryOpenOrders->count());
        // Completed order count
        $queryCompletedOrders = $this->Orders->find('all')
            ->where(['status IN' => ['completed', 'cancelled']]);
        $this->set('completedOrderCount', $queryCompletedOrders->count());
        // Latest regular pricing
        $this->loadModel('ServicePricings');
        $regularGas = $this->ServicePricings->get(3);
        $this->set('regularPrice', $regularGas->cost);
        // Active promo count
        $this->loadModel('Promos');
        $queryPromos = $this->Promos->find('all')
            ->where(['expires >' => new \DateTime()])
            ->andWhere(function($exp) {
                return $exp->or_(['max_uses IS' => null, 'uses < max_uses']);
            });
        $this->set('promoCount', $queryPromos->count());
        // Service area count
        $this->loadModel('ServiceAreas');
        $queryServiceAreas = $this->ServiceAreas->find('all');
        $this->set('serviceAreaCount', $queryServiceAreas->count());
        // User count
        $this->loadModel('Users');
        $queryUsers = $this->Users->find('all');
        $this->set('userCount', $queryUsers->count());
        // Manager count
        $this->loadModel('Managers');
        $queryManagers = $this->Managers->find('all');
        $this->set('managerCount', $queryManagers->count());

        if (!array_key_exists('_serialize', $this->viewVars) &&
            in_array($this->response->type(), ['application/json', 'application/xml'])
        ) {
            $this->set('_serialize', true);
        }
    }
}
