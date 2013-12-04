
app.controller('HotelsCtrl', ['$scope', '$rootScope', '$http', '$routeParams', '$timeout', '$location', '$filter', 'SearchHotels', 'HotelRooms', 'Page',  
  function ($scope, $rootScope, $http, $routeParams, $timeout, $location, $filter, SearchHotels, HotelRooms, Page) { 

    // if(!$routeParams['currency'])$routeParams['currency']='GBP'

        // $rootScope.$on("$routeChangeStart", function(e) {
        //     //show indicator
        //     $rootScope.$broadcast("loading-started");
        // });

    var data = { hotels: [], calls: 1, amenities: [], starRatings: [] };
    $rootScope.Page = Page;

    var param = function(name, default_val){
      return  $routeParams[name] || $location.search()[name] || default_val;
    }

    var end_date = function(){
      // var date = Page.criteria().end_date ? Page.criteria().end_date : param('end_date')
      var date = angular.element('#end_date').datepicker('getDate')
      return $filter('date')(date, 'yyyy-MM-dd')
    }

    var start_date = function(){
      // var date = Page.criteria().start_date ? Page.criteria().start_date : param('start_date')
      var date = angular.element('#start_date').datepicker('getDate')
      return $filter('date')(date, 'yyyy-MM-dd')
    }    

    $rootScope.search = function(isUpdate) {
      


      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();

      if(!isUpdate)
        $rootScope.$broadcast("loading-started");
      // if(Page.info().slug)
      //   $routeParams.id = Page.info().slug

      console.log('Making request. Is update:  ' + isUpdate)
      SearchHotels.get($routeParams,function(response){
       
        console.log('Made request. Finished is:  ' + response.finished)
        if(response.finished===true)    
          $rootScope.$broadcast("loading-complete");  


        data.calls++;
        Page.setCriteria(response.criteria);
        Page.setInfo(response.info);
        $scope.search_results = response
        $rootScope.currency_symbol = Page.criteria().currency_symbol;
        $scope.slug = Page.info().slug
        $rootScope.channel = Page.info().channel
        Hot5.Connections.Pusher.changeChannel($rootScope.channel);
        $("#priceSlider").ionRangeSlider("update", {
            min:  Math.round(10),
            max:  Math.round(Page.info().max_price),
            from: Math.round(Page.info().min_price_filter || 10),                       // change default FROM setting
            to:   Math.round(Page.info().max_price_filter || Page.info().max_price),                         // change default TO setting
        });
        angular.element('#search-input').val('')
        angular.element('#start_date').datepicker('update', new Date(Date.parse(Page.criteria().start_date)));
        angular.element('#end_date').datepicker('update', new Date(Date.parse(Page.criteria().end_date)));
        

        // delete $routeParams['id']
        // $location.search($routeParams).path(Page.info().slug);
        // if(!response.finished && data.calls < 6)
        //   $timeout(pollSearch, 1500);
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

    $scope.saving = function(hotel){
      return Math.floor( (1-(hotel.offer.min_price / hotel.offer.max_price))*100)
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
      console.log(hotel.rooms.length)
    };

    // $rootScope.search = function(){
      
    //   $routeParams['id']
    //   $routeParams.start_date = start_date();
    //   $routeParams.end_date = end_date();
    //   // var url = $location.absUrl()
      
    //   $rootScope.query();
    //   // var newUrl = $location.search($routeParams).path(Page.info().slug);
    //   // if(url===newUrl)
    //   // {
    //   //   console.log(url)
    //   //   $window.location.href = url;
    //   // }
    //   // $rootScope.pollSearch
    //   data.calls = 1;
    // }

    $rootScope.safeApply = function( fn ) {
      var phase = this.$root.$$phase;
      (phase == '$apply' || phase == '$digest') ? fn() : this.$apply(fn);
    }

    $scope.sort = function(sort){
      $routeParams.sort = sort;   
      $scope.search();
    }

    $scope.headerImage = function(hotel){
      if(hotel.images.length>0){
        return hotel.images[0].url;
      }
      return 'http://d1pa4et5htdsls.cloudfront.net/images/61/2025/68208/68208-rev1-img1-400.jpg'
    }

    $rootScope.changePrice = function(min_price, max_price){

      $routeParams.min_price = min_price;
      $routeParams.max_price = max_price;

      if(min_price<=10)
        delete $routeParams.min_price

      if(max_price===0)
        delete $routeParams.max_price
      else if(max_price < min_price)
        max_price = min_price

      $rootScope.search();
    }

    $rootScope.filterAmenities = function (amenity) {
      var idx = data.amenities.indexOf(amenity);
      if (idx > -1) 
        data.amenities.splice(idx, 1);
      else
        data.amenities.push(amenity);
      $routeParams.amenities = data.amenities.join(',');
      $rootScope.search();
    }

    $rootScope.filterStarRatings = function (star_rating) {
      var idx = data.starRatings.indexOf(star_rating);
      if (idx > -1) 
        data.starRatings.splice(idx, 1);
      else
        data.starRatings.push(star_rating);
      $routeParams.star_ratings = data.starRatings.join(',');
      if($routeParams.star_ratings==='')
        delete $routeParams.star_ratings
      $rootScope.search();
    }

    $rootScope.cities = function(cityName) {
      return $http.get("/locations.json?query="+cityName).then(function(response){
        return response.data;
      });
    };

    $rootScope.searchCity = function(){
      // $rootScope.$broadcast("loading-started");
      $routeParams.id = Page.info().slug;
      $location.path(Page.info().slug)
      $rootScope.search();
      // $location.search({start_date: start_date(), end_date: end_date()}).path(Page.info().slug)
    }

   $rootScope.citySelect = function (query, slug) {
      Page.info().slug = slug
    };

    $timeout(function(){
      // $rootScope.$broadcast("loading-started");
      $rootScope.search(false);
    }, 50);
    
    

}]);
