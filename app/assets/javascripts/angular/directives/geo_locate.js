app.directive( 'geoLocate', ['$location', '$window', function($location, $window) {


  var _onSearchSubmitGeo = function(e) {
    var searchInput = $("#search-input");
    if (searchInput.val() != "My Location")
        return true;

    app._startGeoSearch();
    return false;
  }

  return function ( scope, element, attrs ) {
     if (!navigator.geolocation)
      return;

    element.show();
    var searchInput = angular.element("#search-input");

    $("#search").submit(_onSearchSubmitGeo);

    if (searchInput.val())
        return;

    searchInput.focus(function(){
      var self = $(this)
      if(self.val() == "My Location")          
      {
        scope.$apply(function(){
          searchInput.val('')
          scope.slug = undefined
        })
      }
    })

    element.bind( 'click', function () {
      scope.$apply( function () {
        searchInput.val("My Location");
        angular.element("#start_date").datepicker('update', 'today')
        angular.element("#end_date").datepicker('update', '+1d')
        scope.slug = 'my-location'
        return false;
      });
    });
  };
}]);