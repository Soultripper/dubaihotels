
app.controller('HotelsCtrl', ['$scope', '$rootScope', '$http', '$routeParams', '$timeout', '$location', '$filter', 'SearchHotels', 'HotelRooms', 'Page', 'HotelProvider','HotelFactory',  
  function ($scope, $rootScope, $http, $routeParams, $timeout, $location, $filter, SearchHotels, HotelRooms, Page, HotelProvider, HotelFactory) { 

    $scope.hotelProvider = HotelProvider;    
    $rootScope.Page = Page;

    var param = function(name, default_val){
      return  $routeParams[name] || $location.search()[name] || default_val;
    }

    var start_date = function(){
      var date = $scope.start_date ? $scope.start_date : param('start_date')
      return $filter('date')(date, 'yyyy-MM-dd')
    }    

    var end_date = function(){
      var date = $scope.end_date ? $scope.end_date : param('end_date')
      return $filter('date')(date, 'yyyy-MM-dd')
    }

    var tuttimer = [];
    var timeoutId;
    var startLoader = function() {
      $("#results .loader .progress-bar").width("0%");
      timeoutId = $timeout(function() {                  
        $(".loader").fadeIn('fast');
        $(".overlay").fadeIn('fast');

        var total = 10;
        _(total).times(function(i){
          var timeout = i * 500;

          tuttimer.push($timeout(function() {
              var percent = ((i + 1) / total) * 100;
              $("#results .loader .progress-bar").width(percent + "%");

              if (i+1==total) {
                $timeout(function () {
                  $(".overlay").fadeOut('fast');
                  $(".loader").fadeOut('fast'); 
                }, 500);
              }
          }, timeout))
        })
      }, 1000);
    };

    var stopLoader = function(){
      $timeout.cancel(timeoutId);
      for (var i = 0; i < tuttimer.length; i++) {
        $timeout.cancel(tuttimer[i])
      }
      
      $timeout(function() {
        $(".overlay").fadeOut('fast');
        $(".loader").fadeOut('fast');                    
      }, 500);
    };

    $scope.search = function(isUpdate) {
      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();
      $routeParams.page_no = param('page_no', 1)
      $routeParams.sort = param('sort', 'recommended')

      if(!isUpdate) startLoader();

      var url = $location.path() +'.json?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date

      if($routeParams.min_price)
        url += '&min_price=' + $routeParams.min_price;
      if($routeParams.max_price)
        url += '&max_price=' + $routeParams.max_price;
      if($routeParams.sort)
        url += '&sort=' + $routeParams.sort;
      if($routeParams.star_ratings)
        url += '&star_ratings=' + $routeParams.star_ratings;
      if($routeParams.amenities)
        url += '&amenities=' + $routeParams.amenities;
      if($routeParams.page_no)
        url += '&page_no=' + $routeParams.page_no;
      console.log(url)
      $http.get(url).success($scope.setupPage)
    };

    $scope.setupPage = function(response){
      console.log('State is:  ' + response.state)
      // console.log(response)
      $scope.start_date = response.criteria.start_date;
      $scope.end_date = response.criteria.end_date;
      
      if(response.state==='finished')
      {
        stopLoader();
        // $rootScope.$broadcast("loading-complete");  
        Hot5.Connections.Pusher.unsubscribe($rootScope.channel);
        $scope.unsubscribed = true
      }
      else if($scope.unsubscribed===true){
        Hot5.Connections.Pusher.subscribe($rootScope.channel);
        $scope.unsubscribed = false
      }
      
      Page.criteria = response.criteria;
      Page.info = response.info;
      $scope.search_results = response
      $rootScope.currency_symbol = Page.criteria.currency_symbol;
      $scope.slug = Page.info.slug
      $rootScope.channel = Page.info.channel
      Hot5.Connections.Pusher.changeChannel($rootScope.channel);
      updateSlider(response.info);
      angular.element('#search-input').val('')
      angular.element('#start_date').datepicker('update', new Date(Date.parse($scope.start_date)));
      angular.element('#end_date').datepicker('update', new Date(Date.parse($scope.end_date)));
      Page.showlocationMap('location-map', Page.info.longitude, Page.info.latitude)      
    };

    var updateSlider = function(info)
    {
      var slider = angular.element('#priceSlider')
      if(slider)
      {
        slider.ionRangeSlider("update", {
            min:  Math.round(30),
            max:  Math.round(info.max_price),
            from: Math.round(info.min_price_filter || 30),               // change default FROM setting
            to:   Math.round(info.max_price_filter || info.max_price),   // change default TO setting
        });
      } 
    };

    $scope.isSort = function(option){
      return option === (Page.info.sort || 'recommended')
    };

    $scope.providers = function(hotel){
      return _.sortBy(hotel.providers, function(provider){
        return provider.min_price;
      })
    };

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

      if(hotel.rooms && hotel.rooms.length > 0)
        return;

      hotel.displayRooms = false

      var timeoutId = $timeout(function(){
        console.log('forced closure')
        hotel.displayRooms = true
      }, 3000)

      if(Hot5.Connections.Pusher.isHotelSubscribed(hotel.channel))
      {
        roomsQuery(hotel, timeoutId)
      }
      else
      {
        Hot5.Connections.Pusher.subscribeHotel(hotel.channel, 
          function(){ roomsQuery(hotel, timeoutId) },
          function(push_message){ roomsQuery(hotel, timeoutId)});
      }
    };

    var roomsQuery = function(hotel, timeoutId){
      HotelRooms.query({id: hotel.id, currency: param('currency', 'GBP'), end_date: param('end_date'), start_date: param('start_date')}, 
        function(response)
        {
          hotel.rooms = response.rooms    
          if(response.finished===true)
          {
            $timeout.cancel(timeoutId);
            hotel.displayRooms = true;
            Hot5.Connections.Pusher.unsubscribeHotel(hotel.channel)
          }
        }); 
    };

    $rootScope.safeApply = function( fn ) {
      var phase = this.$root.$$phase;
      (phase == '$apply' || phase == '$digest') ? fn() : this.$apply(fn);
    };

    $scope.sort = function(sort){
      $routeParams.sort = sort;   
      $scope.search();
    };

    $scope.headerImage = function(hotel){
      if(hotel.images.length>0){
        return hotel.images[0].url;
      }
      return 'http://d1pa4et5htdsls.cloudfront.net/images/61/2025/68208/68208-rev1-img1-400.jpg'
    };

    $scope.providerImage = function(provider){
      if(provider)
        return 'assets/logos/' + provider + '.gif'
      return ''    
    };

    $rootScope.changePrice = function(min_price, max_price){

      $routeParams.min_price = min_price;
      $routeParams.max_price = max_price;

      if(min_price<=10)
        delete $routeParams.min_price

      if(max_price===0)
        delete $routeParams.max_price
      else if(max_price < min_price)
        max_price = min_price

      $scope.search();
    };

    $rootScope.filterAmenities = function (amenity) {
      var amenities = Page.info.amenities;
      var idx = amenities.indexOf(amenity);
      if (idx > -1) 
        amenities.splice(idx, 1);
      else
        amenities.push(amenity);
      $routeParams.amenities = amenities.join(',');
      if($routeParams.amenities==='')
        delete $routeParams.amenities
      $scope.search();
    };

    $rootScope.filterStarRatings = function (star_rating) {

      star_rating = star_rating.toString();
      var star_ratings = Page.info.star_ratings;

      if(!star_ratings)
        star_ratings = [];

      var idx = star_ratings.indexOf(star_rating);
      if (idx > -1) 
        star_ratings.splice(idx, 1);
      else
        star_ratings.push(star_rating);

      $routeParams.star_ratings = star_ratings.join(',');
      if($routeParams.star_ratings==='')
        delete $routeParams.star_ratings
      $scope.search();
    };

    $rootScope.containsStarRating = function(star_rating){
      var star_ratings = Page.info.star_ratings;
      if(star_ratings)
        return star_ratings.indexOf(star_rating) > -1
      return false
    };

    $rootScope.containsAmenity = function(amenity){
      var amenities = Page.info.amenities;
      if(amenities)
        return amenities.indexOf(amenity) > -1
      return false
    };

    $rootScope.cities = function(cityName) {
      return $http.get("/locations.json?query="+cityName).then(function(response){
        return response.data;
      });
    };

    $rootScope.searchCity = function(){
      // $rootScope.$broadcast("loading-started");
      console.log('city search')
      $routeParams.id = Page.info.slug;
      $location.path(Page.info.slug)
      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();
      $routeParams.page_no = param('page_no', 1)
      // $location.path($routeParams.id +'.json?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date)
      // $scope.search();
      // $location.search({start_date: start_date(), end_date: end_date()}).path(Page.info.slug)

      window.location.href = $routeParams.id + '?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date + '&page_no=' + $routeParams.page_no
    };

   $scope.citySelect = function (query, slug) {
      Page.info.slug = slug
    };


    // $scope.search(false);
    // function(){
    //   // $rootScope.$broadcast("loading-started");
    //   $scope.search(false);
    // }();
  
  var init = function(){
    startLoader();
    console.log('initiated')
    var slider = angular.element('#priceSlider')
    slider.ionRangeSlider({
      type: 'double', 
      prefix: '£',
      hideMinMax: true,
      hideFromTo: true,
      min: 30,
      from: 30,
      to: 1000,
      step: 5,
      onFinish: Hotels.priceRange.change
    })
    $timeout(function() {
      $scope.search(true)                 
    }, 3500);
  }();
  


}]);


