
app.controller('SearchResultsCtrl', ['$scope', '$rootScope', '$routeParams', '$timeout', '$location', 'SearchHotels', 'HotelRooms', 'Page',  
  function ($scope, $rootScope, $routeParams, $timeout, $location, SearchHotels, HotelRooms, Page) { 

    // if(!$routeParams['currency'])$routeParams['currency']='GBP'
      
    var data = { hotels: [], calls: 1, amenities: [] };
    $scope.Page = Page;

    var param = function(name, default_val){
      return  $routeParams[name] || $location.search()[name] || default_val;
    }

    var end_date = function(){
      return Page.criteria().end_date ? Page.criteria().end_date : param('end_date')
    }

    var start_date = function(){
      return Page.criteria().start_date ? Page.criteria().start_date : param('start_date')
    }    

    var pollSearch = function() {
      if(!$routeParams.id) return;     

      SearchHotels.get($routeParams, function(response){
        data.calls++;
        Page.setCriteria(response.criteria);
        Page.setInfo(response.info);
        $scope.search_results = response
        $scope.currency_symbol = Page.criteria().currency_symbol;

        $("#priceSlider").ionRangeSlider("update", {
            min:  Math.round(10),
            max:  Math.round(Page.info().max_price),
            from: Math.round(Page.info().min_price_filter || 10),                       // change default FROM setting
            to:   Math.round(Page.info().max_price_filter || Page.info().max_price),                         // change default TO setting
        });

        if(!response.finished && data.calls < 6)
          $timeout(pollSearch, 3000);
      })
    };

    $scope.isSort = function(option){
      return option === (Page.info().sort || 'recommended')
    }

    $scope.findProvider = function(hotel, providerName){
      var providerResult =  _.find(hotel.providers, function(provider){ 

        return provider ? provider.provider === providerName : false;
      });
      return providerResult === undefined ? {min_price: 0} : providerResult
    }

    $scope.ratingsRange = function(rating){
      return _.range(0, rating)
    }

    $scope.getRooms = function(hotel) {
      if(hotel.rooms){
        hotel.rooms = null;
        return;
      }
      hotel.rooms = HotelRooms.query({id: hotel.id, currency: param('currency', 'GBP'), end_date: param('end_date'), start_date: param('start_date')});
    };

    $rootScope.search = function(){
      $location.search($routeParams)
      data.calls = 1;
    }

    $rootScope.safeApply = function( fn ) {
      var phase = this.$root.$$phase;
      (phase == '$apply' || phase == '$digest') ? fn() : this.$apply(fn);
    }

    $scope.sort = function(sort){
      $routeParams.sort = sort;   
      $scope.search();
    }

    $scope.changePrice = function(min_price, max_price){
      $routeParams.min_price = min_price;
      $routeParams.max_price = max_price;
      $scope.search();
    }


    $scope.filterAmenities = function (amenity) {
      var idx = data.amenities.indexOf(amenity);
      if (idx > -1) 
        data.amenities.splice(idx, 1);
      else
        data.amenities.push(amenity);
      $routeParams.amenities = data.amenities.join(',');
      $scope.search();
    }

    // $scope.filterAmenities = function(amenity){
    //   console.log(this)
    //   $routeParams.amenities = amenity;
    //   //$scope.search();
    // }

    pollSearch();

}]);
