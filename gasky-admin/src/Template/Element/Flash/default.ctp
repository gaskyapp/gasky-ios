<?php
$class = 'message';
if (!empty($params['class'])) {
    $class .= ' ' . $params['class'];
}
?>
<div class="callout <?= h($class) ?>"><?= h($message) ?></div>
