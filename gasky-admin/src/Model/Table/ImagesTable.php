<?php
namespace App\Model\Table;

use Cake\ORM\Table;
use Cake\Validation\Validator;

class ImagesTable extends Table {
  public function initialize(array $config) {
    $this->addBehavior('Timestamp');
    $this->addBehavior('Proffer.Proffer', [
      'image' => [
        'root' => WWW_ROOT . 'files',
        'dir' => 'image_dir',
        'thumbnailMethod' => 'imagick'
      ]
    ]);
    $this->belongsTo('Orders', [
      'foreignKey' => 'entity_id'
    ]);
    
    $listener = new \App\Event\UploadFilenameListener();
    $this->eventManager()->on($listener);
  }

  public function validationDefault(Validator $validator) {    
    return $validator
      ->allowEmpty('image')
      ->add('image', [
        'extension' => [
          'rule' => 'extension',
          'message' => __('A valid image extension of gif, jpeg, png or jpg must be used.')
        ],
        'fileSize' => [
          'rule' => array('fileSize', '<=', '3MB'),
          'message' => __('Image must be less than 3MB.')
        ],
        'mimeType' => [
          'rule' => ['mimeType', ['image/gif', 'image/png', 'image/jpg', 'image/jpeg']],
          'message' => __('File uploaded must be an image of type gif, png, jpg or jpeg.')
        ],
        'uploadError' => [
          'rule' => 'uploadError',
          'message' => __('The image upload failed.'),
          'last' => true
        ]
      ]);
  }
}
