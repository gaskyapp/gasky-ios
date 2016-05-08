<?php
/**
 * Routes configuration
 *
 * In this file, you set up routes to your controllers and their actions.
 * Routes are very important mechanism that allows you to freely connect
 * different URLs to chosen controllers and their actions (functions).
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @license       http://www.opensource.org/licenses/mit-license.php MIT License
 */

use Cake\Core\Plugin;
use Cake\Routing\RouteBuilder;
use Cake\Routing\Router;

/**
 * The default class to use for all routes
 *
 * The following route classes are supplied with CakePHP and are appropriate
 * to set as the default:
 *
 * - Route
 * - InflectedRoute
 * - DashedRoute
 *
 * If no call is made to `Router::defaultRouteClass()`, the class used is
 * `Route` (`Cake\Routing\Route\Route`)
 *
 * Note that `Route` does not do any inflections on URLs which will result in
 * inconsistently cased URLs when used with `:plugin`, `:controller` and
 * `:action` markers.
 *
 */
Router::defaultRouteClass('DashedRoute');

Router::scope('/', function (RouteBuilder $routes) {
    /**
     * Here, we are connecting '/' (base path) to a controller called 'Pages',
     * its action called 'display', and we pass a param to select the view file
     * to use (in this case, src/Template/Pages/home.ctp)...
     */
    $routes->connect('/', ['controller' => 'Orders', 'action' => 'index']);
    
    /**
     * ...and connect the manager login path.
     */
    $routes->connect('/login', ['controller' => 'Managers', 'action' => 'login']);

    /**
     * ...and connect the rest of 'Pages' controller's URLs.
     */
    //$routes->connect('/pages/*', ['controller' => 'Pages', 'action' => 'display']);

    /**
     * Connect catchall routes for all controllers.
     *
     * Using the argument `DashedRoute`, the `fallbacks` method is a shortcut for
     *    `$routes->connect('/:controller', ['action' => 'index'], ['routeClass' => 'DashedRoute']);`
     *    `$routes->connect('/:controller/:action/*', [], ['routeClass' => 'DashedRoute']);`
     *
     * Any route class can be used with this method, such as:
     * - DashedRoute
     * - InflectedRoute
     * - Route
     * - Or your own route class
     *
     * You can remove these routes once you've connected the
     * routes you want in your application.
     */
    $routes->fallbacks('DashedRoute');
});

Router::prefix('api', function ($routes) {
    /**
    * Router resource notes:
    * - PaymentMethods->Add action assigns a new payment method to an auth user using
    *   Braintree's paymentMethodNonce
    * - PaymentMethods->Default action assigns a payment method as default by id
    * - Orders->Add action posts a new order from an auth user
    * - Orders->Feedback action posts feedback for an order
    * - Promos->Add action assigns a promo to an auth user's account by code
    * - Promos->Remove action removes an auth user's current promo
    * - Users->Token action added for post method to allow for api logins
    *
    * Notes omitted for resources routes with default handling.
    */
    $routes->extensions(['json']);
    $routes->resources('Promos', ['only' => ['view'], 'id' => '\w+']);
    $routes->resources('ServiceAreas', ['only' => ['index']]);
    $routes->resources('ServicePricings', ['only' => ['index']]);
    $routes->resources('Users', [
        'only' => ['create', 'token', 'update', 'view'],
        'map' => [
            'token' => [
                'action' => 'token',
                'method' => 'POST'
            ]
        ]
    ], function ($routes) {
        $routes->resources('PaymentMethods', [
            'only' => ['create', 'delete', 'index', 'primary', 'view'],
            'map' => [
                'primary' => [
                    'action' => 'primary',
                    'method' => 'POST'
                ]
            ]
        ]);
        $routes->resources('Orders', [
            'only' => ['create', 'view'],
            'map' => [
                'feedback' => [
                    'action' => 'feedback',
                    'method' => 'POST'
                ]
            ]
        ]);
        $routes->resources('Promos', [
            'only' => ['create', 'remove'],
            'map' => [
                'remove' => [
                    'action' => 'remove',
                    'method' => 'DELETE'
                ]
            ]
        ]);
    });
});

/**
 * Load all plugin routes.  See the Plugin documentation on
 * how to customize the loading of plugin routes.
 */
Plugin::routes();
