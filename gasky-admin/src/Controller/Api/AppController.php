<?php
namespace App\Controller\Api;

use Cake\Core\Configure;
use Cake\Controller\Controller;
use Cake\Event\Event;

class AppController extends Controller {
  use \Crud\Controller\ControllerTrait;

  public function initialize() {
    parent::initialize();

    $this->loadComponent('RequestHandler');
    $this->loadComponent('Crud.Crud', [
      'actions' => [
        'Crud.Index',
        'Crud.View',
        'Crud.Add',
        'Crud.Edit',
        'Crud.Delete'
      ],
      'listeners' => [
        'Crud.Api',
        'Crud.ApiQueryLog'
      ]
    ]);

    $this->loadComponent('Auth', [
      'storage' => 'Memory',
      'authenticate' => [
        'Form' => [
          'fields' => [
            'username' => 'email',
            'password' => 'password'
          ]
        ],
        'ADmad/JwtAuth.Jwt' => [
          'userModel' => 'Users',
          'fields' => [
            'username' => 'id'
          ],
          'parameter' => 'token',
          'queryDatasource' => true,
          'unauthenticatedException' => '\Cake\Network\Exception\UnauthorizedException'
        ]
      ],
      'unauthorizedRedirect' => false,
      'checkAuthIn' => 'Controller.initialize',
      'loginAction' => false
    ]);
    
    \Braintree\Configuration::environment(Configure::read('Braintree.environment'));
    \Braintree\Configuration::merchantId(Configure::read('Braintree.merchantId'));
    \Braintree\Configuration::publicKey(Configure::read('Braintree.publicKey'));
    \Braintree\Configuration::privateKey(Configure::read('Braintree.privateKey'));  
  }
  
  // Utility for querying and assigning payment method data from Braintree
  protected function _assignPaymentMethodData($payment_methods) {
    if (is_array($payment_methods)) {
      foreach ($payment_methods as $key => $value) {
        $payment_gateway_details = $payment_methods[$key]->returnBraintreeData();
        $payment_methods[$key]->card_type = $payment_gateway_details->cardType;
        $payment_methods[$key]->default = ($payment_gateway_details->default ? true : false);
        $payment_methods[$key]->digits = $payment_gateway_details->last4;
        $payment_methods[$key]->expiration_date = $payment_gateway_details->expirationDate;
        $payment_methods[$key]->expired = ($payment_gateway_details->expired ? true : false);
        $payment_methods[$key]->zip = $payment_gateway_details->billingAddress->postalCode;
        unset($payment_methods[$key]->user_id);
      }
      return $payment_methods;
    } else {
      $payment_gateway_details = $payment_methods->returnBraintreeData();
      $payment_methods->card_type = $payment_gateway_details->cardType;
      $payment_methods->default = ($payment_gateway_details->default ? true : false);
      $payment_methods->digits = $payment_gateway_details->last4;
      $payment_methods->expiration_date = $payment_gateway_details->expirationDate;
      $payment_methods->expired = ($payment_gateway_details->expired ? true : false);
      $payment_methods->zip = $payment_gateway_details->billingAddress->postalCode;
      unset($payment_methods->user_id);
      return $payment_methods;
    }
  }
}
