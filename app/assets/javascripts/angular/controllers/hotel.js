
app.controller('HotelCtrl', ['$scope', '$rootScope', '$http', '$routeParams', '$timeout', '$location', '$filter', 'SearchHotels', 'HotelRooms', 'Page', 'HotelProvider','HotelFactory',  
  function ($scope, $rootScope, $http, $routeParams, $timeout, $location, $filter, SearchHotels, HotelRooms, Page, HotelProvider, HotelFactory) { 

    var timeoutId, initTimeoutId;

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

    $scope.search = function(callback) {
      console.log('calling search')
      if(!callback)
        callback = $scope.setupPage;

      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();

      var url = $location.path() +'.json?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date
      $http.get(url).success(callback)
    };

    $scope.setupPage = function(response){
      $scope.setupHeader(response.criteria);
      $scope.search_results = response
     
      $rootScope.channel = Page.info.channel
      $scope.hotel = response.hotel;
      $scope.slug = 'hotels/' + $scope.hotel.id 
      loadMap();
      $scope.getRooms()

      $(".thumbs li:first a").click();
      Hot5.Connections.Pusher.changeChannel($rootScope.channel);


    };

    $scope.setupHeader = function(criteria){
      Page.criteria = criteria;

      $rootScope.currency_symbol = criteria.currency_symbol;
      $scope.start_date = criteria.start_date;
      $scope.end_date = criteria.end_date;   

      angular.element('#search-input').val('')
      // angular.element('#start_date').datepicker('update', new Date(Date.parse($scope.start_date)));
      // angular.element('#end_date').datepicker('update', new Date(Date.parse($scope.end_date))); 

    }

    $scope.checkAmenity = function(amenityMask){
      var amenities = $scope.hotel.amenities;
      if(amenities)
        return (amenityMask | amenities) === amenities
      return false;
    }

    $scope.getRooms = function() {

      var rooms = $scope.hotel.rooms;

      if(rooms && rooms.length > 0)
        return;

      $scope.hotel.displayRooms = false

      var timeoutId = $timeout(function(){
        $scope.hotel.displayRooms = true
      }, 4500)

      if(Hot5.Connections.Pusher.isHotelSubscribed($scope.hotel.channel))
      {
        roomsQuery(timeoutId)
      }
      else
      {
        Hot5.Connections.Pusher.subscribeHotel($scope.hotel.channel, 
          function(){ roomsQuery(timeoutId) },
          function(push_message){ roomsQuery(timeoutId)});
      }
    };

    $scope.showImage = function(e, image){
      return app.loadImage(e.srcElement, image.url);
    };

    var roomsQuery = function( timeoutId){
      var hotel = $scope.hotel;
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

    $scope.headerImage = function(){
      var hotel = $scope.hotel;
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



    $rootScope.cities = function(cityName) {
      return $http.get("/locations.json?query="+cityName).then(function(response){
        return response.data;
      });
    };

    $rootScope.searchCity = function(){
      // $rootScope.$broadcast("loading-started");
      $routeParams.id = $scope.slug;
      $location.path($scope.slug);
      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();
      // $location.path($routeParams.id +'.json?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date)
      // $scope.search();
      // $location.search({start_date: start_date(), end_date: end_date()}).path(Page.info.slug)

      window.location.href = '/' + $routeParams.id + '?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date
    };

   $scope.locationSelect = function (query, slug, type) {
      $scope.selectType = type;
      $scope.slug = slug
    };

    // $scope.search(false);
    // function(){
    //   // $rootScope.$broadcast("loading-started");
    //   $scope.search(false);
    // }();

    var loadMap = function(){
      var map_container = document.getElementById('hotel_map');
      var mapCenter = {center: new google.maps.LatLng($scope.hotel.latitude, $scope.hotel.longitude)};   
      var mapOptions = {
        zoom: 15,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      var map = new google.maps.Map(map_container, $.extend( mapCenter, mapOptions ));

      var marker = new google.maps.Marker({
          position: mapCenter.center,
          map: map
      });  
    }
  
  var init = function(){
    // $scope.search();

  };

  init();
  


}]);


