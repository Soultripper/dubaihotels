app = angular.module('SearchResults', ['ngResource', 'ngSanitize', 'ngRoute']).config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {

 $routeProvider.when('/:id', {
    templateUrl: 'templates/hotels.html',
    controller: 'SearchResultsCtrl'
  })

  $locationProvider.html5Mode(true);
}]);
