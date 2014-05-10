
app.controller('HotelCtrl', ['$scope', '$rootScope', '$http', '$routeParams', '$timeout', '$location', '$filter', 'HotelResults', 'HotelRooms', 'Page', 'HotelProvider','HotelFactory',  
  function ($scope, $rootScope, $http, $routeParams, $timeout, $location, $filter, HotelResults, HotelRooms, Page, HotelProvider, HotelFactory) { 

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

    // $scope.search = function(callback) {
    //   if(!callback)
    //     callback = $scope.setupPage;

    //   $routeParams.start_date = start_date();
    //   $routeParams.end_date = end_date();

    //   var url = $location.path() +'.json?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date
    //   $http.get(url).success(callback)
    // };

    $scope.initPage = function(initData){
      $scope.setupHeader(initData.criteria);
      $scope.search_results = initData    
     
      $scope.hotel = initData.hotel;
      $scope.slug = 'hotels/' + $scope.hotel.slug 
      loadMap();
      $scope.getRooms()

      $(".thumbs li:first a").click();
      
    }

    $scope.buildParams = function(){

      var params = {},
          qs  = $location.search()

      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();

      params.start_date   = $routeParams.start_date;
      params.end_date     = $routeParams.end_date;
      params.coordinates  = qs.coordinates;

      return params;
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

      var hotel = $scope.hotel;
      var rooms = hotel.rooms;

      if(rooms && rooms.length > 0)
        return hotel.displayRooms = true;

      hotel.displayRooms = false

      // var timeoutId = $timeout(function(){
      //   $scope.hotel.displayRooms = true
      // }, 4500)

      if(Hot5.Connections.Pusher.isHotelSubscribed(hotel.channel))
      {
        roomsQuery(timeoutId)
      }
      else
      {
        Hot5.Connections.Pusher.subscribeHotel(hotel.channel, 
          function(){ roomsQuery(timeoutId) },
          function(push_message){ roomsQuery(timeoutId)});
      }
    };

    // $scope.getRooms = function(obj) {
    //   var hotel = $scope.hotel;

    //   if(hotel.rooms && hotel.rooms.length > 0)
    //     return hotel.displayRooms = true;
    //   hotel.displayRooms = false
    //   roomsQuery(hotel, timeoutId, obj)
    // };


    // var roomsQuery = function(hotel, timeoutId, obj){
    //   var hotel = $scope.hotel;

    //   Hot5.Connections.Pusher.changeChannel(hotel.channel);

    //   var params = {'key': hotel.key }

    //   HotelResults.get('/hotels/' + hotel.slug + '/rooms', params).success(
    //     function(response){
    //       hotel.rooms = response  
    //       hotel.displayRooms = true;;
    //     });
    // };



    var roomsQuery = function(timeoutId){
      var hotel = $scope.hotel;

      var params = {'key': hotel.key }

      HotelResults.get('/hotels/' + hotel.slug + '/rooms', params).success(
        function(response){
          hotel.rooms = response  
          hotel.displayRooms = true;
          if(response.finished===true)
            Hot5.Connections.Pusher.unsubscribeHotel(hotel.channel)
          
        });
    };

    $scope.showImage = function(e, image){
      return app.loadImage(e.srcElement, image.url);
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

      if($scope.slug==undefined)
        return;

      if($scope.slug=='my-location')
      {
        app._onSearchSubmitGeo();
        return;
      }
      
      // $rootScope.$broadcast("loading-started");
      // $routeParams.id = $scope.slug;
      // $location.path($scope.slug);
      $routeParams.start_date = start_date();
      $routeParams.end_date = end_date();

      if($scope.selectType=='hotel')
        $scope.slug = 'hotels/' + $scope.slug 

      // $location.path($routeParams.id +'.json?start_date=' + $routeParams.start_date + '&end_date=' + $routeParams.end_date)
      // $scope.search();
      // $location.search({start_date: start_date(), end_date: end_date()}).path(Page.info.slug)
      var url = '/' + $scope.slug + '?';
      var qs = []

      if($routeParams.start_date!=undefined)
        qs.push('start_date=' + $routeParams.start_date)

      if($routeParams.end_date!=undefined)
        qs.push('end_date=' + $routeParams.end_date)
      
      window.location.href =  url + qs.join('&');
    };

   $scope.locationSelect = function (query, slug, type) {
      $scope.selectType = type;
      $scope.slug = slug
    };

    $scope.trackClick = function(clickDetails){
      var params = $scope.buildParams();
     
      var url = '/offer/' + clickDetails.provider + '?';
      params.price = clickDetails.price;
      params.hotel_id = clickDetails.hotel_id;
      params.target_url = clickDetails.url;
      Hotels.removeEmptyKeys(params)
      var result = decodeURIComponent($.param(params));
      window.open(url + result);
    }

    $scope.mapWidth = function(){
      var missingImages = 6 - $scope.hotel.images.length;
      if(missingImages <= 0)
        return 16.666;
      return 16.666 * missingImages;
    }

    $scope.ratingsText = Hotels.ratingsText; 

    // $scope.search(false);
    // function(){
    //   // $rootScope.$broadcast("loading-started");
    //   $scope.search(false);
    // }();

    var loadMap = function(){
      var map_container = document.getElementById('hotel_map');

      var lat = $scope.hotel.latitude;
      var lng = $scope.hotel.longitude;

      var mapCenter = {center: new google.maps.LatLng(lat, lng)};   
      var mapOptions = {
        zoom: 15,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      var map = new google.maps.Map(map_container, $.extend( mapCenter, mapOptions ));

      var marker = new google.maps.Marker({
          position: mapCenter.center,
          map: map
      });  

      var fixedMap = Hotels.Map.createFixedMap('small-map', lat, lng)
      var marker = Hotels.Map.createMarker(
        {
          latitude: lat, 
          longitude: lng, 
          name: $scope.hotel.name, 
          map: fixedMap
        });
    }
  


    var init = function(){
      
    };

    // init();

}]);


