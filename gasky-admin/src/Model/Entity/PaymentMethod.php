<?php
namespace App\Model\Entity;

use Cake\ORM\Entity;

class PaymentMethod extends Entity {
  protected $_accessible = [
    '*' => true,
    'id' => false
  ];
  
  protected $_hidden = ['created', 'modified', 'token'];
  
  protected $_paymentGatewayDetails = null;
  
  protected function _retrieveBraintreeData() {
    $this->_paymentGatewayDetails = \Braintree\PaymentMethod::find($this->_properties['token']);
  }
  
  public function returnBraintreeData() {
    return \Braintree\PaymentMethod::find($this->_properties['token']);
  }
  
  protected function _getCardType() {
    if ($this->_paymentGatewayDetails == null) {
      $this->_retrieveBraintreeData();
    }
    return $this->_paymentGatewayDetails->cardType;
  }
  
  protected function _getDefault() {
    if ($this->_paymentGatewayDetails == null) {
      $this->_retrieveBraintreeData();
    }
    return $this->_paymentGatewayDetails->default;
  }
  
  protected function _getDigits() {
    if ($this->_paymentGatewayDetails == null) {
      $this->_retrieveBraintreeData();
    }
    return $this->_paymentGatewayDetails->last4;
  }
  
  protected function _getExpirationDate() {
    if ($this->_paymentGatewayDetails == null) {
      $this->_retrieveBraintreeData();
    }
    return $this->_paymentGatewayDetails->expirationDate;
  }
  
  protected function _getExpired() {
    if ($this->_paymentGatewayDetails == null) {
      $this->_retrieveBraintreeData();
    }
    if ($this->_paymentGatewayDetails->expired) {
      return true;
    }
    return false;
  }
  
  protected function _getZip() {
    if ($this->_paymentGatewayDetails == null) {
      $this->_retrieveBraintreeData();
    }
    return $this->_paymentGatewayDetails->billingAddress->postalCode;
  }
}
