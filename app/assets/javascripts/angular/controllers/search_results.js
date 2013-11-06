
app.controller('SearchResultsCtrl', ['$scope', '$rootScope', '$routeParams', '$timeout', '$location', 'SearchHotels', 'HotelRooms', 'Page',  
  function ($scope, $rootScope, $routeParams, $timeout, $location, SearchHotels, HotelRooms, Page) { 

    var data = { hotels: [], calls: 1 };
    $scope.Page = Page;

    var param = function(name, default_val){
      return  $location.search()[name] || $routeParams[name] || default_val;
    }

    var end_date = function(){
      return Page.criteria().end_date ? Page.criteria().end_date : param('end_date')
    }

    var start_date = function(){
      return Page.criteria().start_date ? Page.criteria().start_date : param('start_date')
    }    

    var pollSearch = function() {
      if(!$routeParams.id) return;     

      SearchHotels.get({id: $routeParams.id, currency: param('currency', 'GBP'), page_no: param('page_no', 1) , sort: param('sort'), start_date: start_date(), end_date: end_date()}, function(response){
        data.calls++;
        Page.setCriteria(response.criteria);
        Page.setInfo(response.info);
        $scope.search_results = response
        $scope.currency_symbol = Page.criteria().currency_symbol;

        $("#priceSlider").ionRangeSlider("update", {
            min: Math.round(Page.info().min_price),
            max: Math.round(Page.info().max_price),
            from: Math.round(Page.info().min_price),                       // change default FROM setting
            to: Math.round(Page.info().max_price),                         // change default TO setting
        });

        if(!response.finished && data.calls < 6)
          $timeout(pollSearch, 3000);
      })
    };
    pollSearch();


    $scope.isSort = function(option){
      return option === Page.info().sort
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
      $location.search(
        {id: $routeParams.id, 
          currency: param('currency', 'GBP'), 
          page_no: param('page_no', 1) , 
          sort: param('sort',''),          
          start_date: start_date(),
          end_date: end_date(), 
        });
      data.calls = 1;
      // console.log($scope.search_results)
      // pollSearch()
    }

    $scope.sort = function(sort){
      $location.search(
        {id: $routeParams.id, 
          currency: param('currency', 'GBP'), 
          page_no: param('page_no', 1) , 
          sort: sort,           
          start_date: start_date(),
          end_date: end_date(), 
        });
    }

}]);
