app = angular.module('SearchResults', ['ngResource', 'ngSanitize']).config(function($routeProvider, $locationProvider) {

 $routeProvider.when('/:id', {
    templateUrl: 'templates/hotels.html',
    controller: 'SearchResultsCtrl'
  })

  $locationProvider.html5Mode(true);
});


var actions = { 
  'get':    {method:'GET', isArray:true}
};
