app = angular.module('Hot5', ['ngResource', 'ngSanitize', 'ngRoute', 'searchHotelsServices','hotelsServices', 'ui.bootstrap']).config(['$routeProvider', '$locationProvider', 
  function($routeProvider, $locationProvider) {
   // $routeProvider.when('/:id', {
   //    templateUrl: 'templates/hotels.html',
   //    controller: 'HotelsCtrl',
   //    reloadOnSearch: false
   //  })

    $locationProvider.html5Mode(true);
  }
]);
