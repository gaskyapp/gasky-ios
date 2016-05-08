<?php
namespace App\Event;

use Cake\Event\Event;
use Cake\Event\EventListenerInterface;
use Cake\Utility\Text;
use Proffer\Lib\ProfferPath;

class UploadFilenameListener implements EventListenerInterface {
  public function implementedEvents() {
    return ['Proffer.afterPath' => 'change'];
  }

  /**
   * Rename a file before it's processed
   *
   * @param Event $event The event class with a subject of the entity
   * @param ProfferPath $path
   * @return ProfferPath $path
   */
  public function change(Event $event, ProfferPath $path) {
    // Detect and select the right file extension
    switch ($event->subject()->get('image')['type']) {
      default:
      case "image/jpeg":
        $ext = '.jpg';
        break;
      case "image/png":
        $ext = '.png';
        break;
      case "image/gif":
        $ext = '.gif';
        break;
    }

    $newFilename = Text::uuid() . $ext;

    $path->setFilename($newFilename);
    $event->subject('image')['name'] = $newFilename;

    return $path;
  }
}