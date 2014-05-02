app.directive( 'getDeal', ['$location', '$window', function($location, $window) {
  return function ( scope, element, attrs ) {
    var path;

    attrs.$observe( 'getDeal', function (val) {
      path = val.link;
    });

    element.bind( 'click', function () {
      var self = $(this);

      var url = path || self.data('get-deal')
     
      if(!url) return;
      var details = {
        provider: self.data('provider'),
        price: accounting.toFixed(self.data('price'),0),
        max_price: accounting.toFixed(self.data('max-price'),0),
        saving: self.data('saving'),
        hotel_id: self.data('hotel-id'),
        url: encodeURIComponent(url)
      }
      // var provider  = this.data('provider'),
      //     price     = this.data('price'),
      //     hotel_id  = this.data('hotelId')

      scope.$apply( function () {
        scope.trackClick(details)
        // $window.open(path);
      });
    });
  };
}]);