app.directive( 'getDeal', ['$location', '$window', function($location, $window) {
  return function ( scope, element, attrs ) {
    var path;

    attrs.$observe( 'getDeal', function (val) {
      path = val;
    });

    element.bind( 'click', function () {
      scope.$apply( function () {
        $window.open(path);
      });
    });
  };
}]);