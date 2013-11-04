
app.controller('SearchResultsCtrl', ['$scope', '$route', '$rootScope', '$routeParams', '$timeout', '$location', '$resource', '$http',  
  function SearchResultsCtrl($scope, $route, $rootScope, $routeParams, $timeout, $location, $resource, $http) {

    var SearchResults = $resource(":id.json/?page_no=:page_no&start_date=:start_date&end_date=:end_date&sort=:sort&currency=:currency", {page_no: 1});
    var HotelRooms    = $resource("hotels/:id.json/?start_date=:start_date&end_date=:end_date&currency=:currency");

    var data = { hotels: [], calls: 1 };

    var param = function(name, default_val){
      return  $location.search()[name] || default_val;
    }

    var poller = function() {
      if(!$routeParams.id) return;

      SearchResults.get({id: $routeParams.id, currency: param('currency', 'GBP'), page_no: param('page_no', 1) , sort: param('sort'), end_date: param('end_date'), start_date: param('start_date')}, function(response) {
        data.calls++;
        $scope.hotels = response.hotels;
        $rootScope.total_hotels = response.total_hotels;
        $rootScope.available_hotels = response.available_hotels;
        $rootScope.currency_symbol = response.criteria.currency_symbol;
        $rootScope.sort = response.sort;

        $scope.toCurrency = function(value){
          if(value <= 0) return "N/A";
          return response.criteria.currency_symbol + value;
        }

        $rootScope.isSort = function(option){
          return option === $rootScope.sort
        }

        $scope.findProvider = function(hotel, providerName){
          var providerResult =  _.find(hotel.providers, function(provider){ 

            return provider ? provider.provider === providerName : false;
          });
          return providerResult === undefined ? {min_price: 0} : providerResult
        }

        $scope.rooms = function(hotel){
          var rooms = _.compact(_.flatten(_.map(hotel.providers, function(provider){ return provider.rooms; })));
          return _.sortBy(rooms, function(room){
            return new Number(room.price);
          })
        }

        $scope.providerImage = function(room){

        }

        if(!response.finished && data.calls < 5)
          $timeout(poller, 1500);
      });      
    };
    poller();

    $scope.ratingsRange = function(rating){
      return _.range(0, rating)
    }

    $scope.getRooms = function(hotel) {
      if(hotel.rooms){
        hotel.rooms = null;
        return;
      }
      hotel.rooms = HotelRooms.query({id: hotel.id});
    };


  // Hotel = $resource("/hotels/:id", {id: '@id'})
  // $scope.hotels = hotelFixtures.hotels
  // console.log(Hotel.data.hotels)
  // $scope.hotels = Hotel.data.hotels
  // var data = Hotel.get(function(response){
  //   $scope.hotels = response.hotels
  // });
  
  // $scope.currency = hotelFixtures.currency;
  // $scope.hotels = hotelFixtures.hotels;
}]);
