var searchHotelsServices = angular.module('searchHotelsServices', ['ngResource']);

// searchHotelsServices.factory('SearchHotels', ['$resource',
//   function($resource){
//     return $resource(":id.json/?page_no=:page_no&start_date=:start_date&end_date=:end_date&sort=:sort&currency=:currency&min_price=:min_price&max_price=:max_price&amenities=:amenities&star_ratings=:star_ratings&coordinates=:coordinates", {}, {
//       get: {method:'GET', params:{page_no: 1}, isArray:false}
//     });
//   }]);

searchHotelsServices.factory('HotelRooms', ['$resource',
  function($resource){
    var resource = $resource("/hotels/:id/rooms.json/?start_date=:start_date&end_date=:end_date&currency=:currency", {}, {query: {method:'GET', params:{page_no: 1}, isArray:false}});
    return resource;
  }]);




searchHotelsServices.factory('HotelProvider', function() {

  // var provider = hotelProvider;
  var getDescription =  function(hotelProvider){
   switch(hotelProvider.provider){
     case 'booking':
       return "Booking.com";
     case 'expedia':
       return "Expedia.co.uk";
     case 'agoda':
       return 'Agoda.com';
     case 'easy_to_book':
       return 'EasyToBook.com';
     case 'splendia':
       return 'Splendia.com';
     // case 'hotels':
     //   return 'Hotels.com';       
     case 'laterooms':
       return 'LateRooms.com';  
     case 'venere':
       return 'Venere.com';           
     default:
       return name; 
     }
   }

  return {
     getDescription: getDescription
  };
});


searchHotelsServices.factory('Page', function() {
   var criteria = {

   };

   var info = {
    available_hotels:0,
    total_hotels:0,    
    star_ratings: [],
    amenities: []
   };

   var hotelsAvailable = function(){
    var hotelCount = this.info.available_hotels
    if(hotelCount>=500)
      return "500+ hotels available";
    if(hotelCount>0)
      return hotelCount + " hotels available"
    return " "
   }

  return {
    criteria: criteria,
    // showlocationMap: showlocationMap,
    // setCriteria: function(newCriteria) { this.criteria = newCriteria },
    info: info,
    hotelsAvailable: hotelsAvailable
    // setInfo: function(newInfo) { this.info = newInfo }
  };
});

searchHotelsServices.factory('Analytics', ['$http', '$location',
  function($http, $location){

    var errors_geolocate = function(){
      post('geolocate_error')
    }

    var post = function(path, data){
      var protocol = $location.protocol(), 
          host     = window.location.host;

      var url =  protocol + '://analytics.' +  Hotels.getDomainName(host)  + '/' + path;
      $http({'method': 'POST', 'url': url, 'data': data})
    }

    return {
      errors:{
          geolocate: errors_geolocate
      }
    };
  }
]);

searchHotelsServices.factory('HotelResults', ['$http', '$location',
  function($http, $location){

    var get = function(path, params){
      var protocol = $location.protocol(), 
          host     = window.location.host;
          console.log(host)
      var url =  protocol + '://hotels.' + Hotels.getDomainName(host) + path;
      return $http({'method': 'GET', 'url': url, 'headers':{'Accept':"application/json"}, 'params': params})
    }

    return {
      get: get
    };
  }]
);

