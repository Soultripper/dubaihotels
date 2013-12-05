app.directive('roomsLoader', ['$timeout', function($timeout) {

  return {
    restrict: 'E',
    transclude: false,
    templateUrl: 'templates/rooms_loader.html',
    link: function(scope, element, attr) {
      }
    }
  }]
);
