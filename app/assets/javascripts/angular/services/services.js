var searchHotelsServices = angular.module('searchHotelsServices', ['ngResource']);

searchHotelsServices.factory('SearchHotels', ['$resource',
  function($resource){
    return $resource(":id.json/?page_no=:page_no&start_date=:start_date&end_date=:end_date&sort=:sort&currency=:currency", {}, {
      get: {method:'GET', params:{page_no: 1}, isArray:false}
    });
  }]);

searchHotelsServices.factory('HotelRooms', ['$resource',
  function($resource){
    return $resource("hotels/:id.json/?start_date=:start_date&end_date=:end_date&currency=:currency", {}, {
      query: {method:'GET', params:{page_no: 1}, isArray:true}
    });
  }]);

searchHotelsServices.factory('Page', function() {
   var criteria = {
   }

   var info={
    available_hotels:0,
    total_hotels:0,
    min_price: 0,
    max_price: 100
   };

   var price_range = function(){
    info.min_price + ";" + info.max_price
   }

   return {
      criteria: function() { return criteria; },
      setCriteria: function(newCriteria) { criteria = newCriteria },
      info: function() { return info; },
      setInfo: function(newInfo) { info = newInfo },
      price_range: price_range
   };
});