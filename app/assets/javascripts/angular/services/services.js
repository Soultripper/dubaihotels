var searchHotelsServices = angular.module('searchHotelsServices', ['ngResource']);

searchHotelsServices.factory('SearchHotels', ['$resource',
  function($resource){
    return $resource(":id.json/?page_no=:page_no&start_date=:start_date&end_date=:end_date&sort=:sort&currency=:currency&min_price=:min_price&max_price=:max_price&amenities=:amenities&star_ratings=:star_ratings", {}, {
      get: {method:'GET', params:{page_no: 1}, isArray:false}
    });
  }]);

searchHotelsServices.factory('HotelRooms', ['$resource',
  function($resource){
    var resource = $resource("hotels/:id.json/?start_date=:start_date&end_date=:end_date&currency=:currency", {}, {query: {method:'GET', params:{page_no: 1}, isArray:false}});
    return resource;
  }]);

searchHotelsServices.factory('Page', function() {
   var criteria = {
    star_ratings: []
   };

   var info = {
    available_hotels:0,
    total_hotels:0
   };

   return {
      criteria: criteria,
      // setCriteria: function(newCriteria) { this.criteria = newCriteria },
      info: info,
      // setInfo: function(newInfo) { this.info = newInfo }
   };
});