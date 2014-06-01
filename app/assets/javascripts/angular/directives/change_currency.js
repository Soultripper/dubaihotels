app.directive( 'changeCurrency', ['$location', '$window', function($location, $window) {

  return function (scope, element, attrs ) {

    element.bind( 'click', function (e) {
     var currency = angular.element(e.target).data('currency');

      scope.changeCurrency(currency);
       return false;
      // scope.$apply( function () {
      //   scope.changeCurrency(currency);
      //   return false;
      // });
    });
  };
}]);