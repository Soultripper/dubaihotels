
app.controller('HotelsCtrl', ['$scope', '$rootScope', '$http', '$routeParams', '$timeout', '$location', '$filter', 'SearchHotels', 'HotelRooms', 'Page', 'HotelProvider','HotelFactory',  
  function ($scope, $rootScope, $http, $routeParams, $timeout, $location, $filter, SearchHotels, HotelRooms, Page, HotelProvider, HotelFactory) { 

    // var searchInput = angular.element('#search-input');
    
    // searchInput.focus(function(){
    //   var self = $(this)
    //   if(self.val() == "My Location")    
    //   {      
    //     self.val('');
    //     $scope.slug = undefined;
    //   }
    // })

    var tuttimer = [];
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
      $timeout.cancel(initTimeoutId);
      for (var i = 0; i < tuttimer.length; i++) {
        $timeout.cancel(tuttimer[i])
      }
      
      $timeout(function() {
        $(".overlay").fadeOut('fast');
        $(".loader").fadeOut('fast');                 
      }, 500);
    };

    var startUpdater = function(){
      $("#results .updater").fadeIn('fast');
      $("#results .overlay").fadeIn('fast');
      $("#map-loader").show();
    };

    var stopUpdater = function(){
      $("#results .updater").fadeOut('fast');
      $("#results .overlay").fadeOut('fast');
      $("#map-loader").hide();
    };

    $scope.search = function(callback) {
      if(!callback)
        callback = $scope.setupPage;

      var params = $scope.buildParams();

      $http.get($location.path(), {
        headers:{'Accept':"application/json"}, 
        params: params
      }).success(callback)
    };

    $scope.buildParams = function(){

      var params = {},
          qs  = $location.search()

      $routeParams.start_date = start_date();
      $routeParams.end_date   = end_date();
      $routeParams.count      = param('count', 15)
      $routeParams.sort       = param('sort')
      $routeParams.currency   = param('currency')
      $routeParams.min_price  = param('min_price')
      $routeParams.max_price  = param('max_price')

      params.start_date   = $routeParams.start_date;
      params.end_date     = $routeParams.end_date;
      params.hotel        = qs.hotel;
      params.count        = $routeParams.count;
      params.min_price    = $routeParams.min_price;
      params.max_price    = $routeParams.max_price;
      params.sort         = $routeParams.sort;
      params.star_ratings = $routeParams.star_ratings;
      params.amenities    = $routeParams.amenities;
      params.coordinates  = qs.coordinates;
      params.load_more    = $routeParams.load_more;
      params.currency     = $routeParams.currency || Page.criteria.currency_code;
      return params;
    };


    $scope.hotelLink = function(hotel){
      var qs = [];
      qs.push('/hotels/');
      qs.push(hotel.slug );
      qs.push('?start_date=' + start_date())
      qs.push('&end_date='   + end_date())
      qs.push('&currency='   + Page.criteria.currency_code)
      return qs.join('')
    };

    $scope.initPage = function(initData){
      Hotels.Map.createFixedMap('location-map', initData.info.latitude, initData.info.longitude, {zoom: initData.info.zoom, draggable: false});

      $scope.start_date = initData.criteria.start_date;
      $scope.end_date = initData.criteria.end_date;
      
      angular.element('#search-input').val('')
      angular.element('#start_date').datepicker('update', new Date(Date.parse($scope.start_date)));
      angular.element('#end_date').datepicker('update', new Date(Date.parse($scope.end_date)));



      $scope.setupPage(initData)
    };

    $scope.setupPage = function(response){
      stopUpdater();

      $scope.pageState = response.state;
      
      if($scope.pageState==='finished')
      {
        stopLoader();
        Hot5.Connections.Pusher.unsubscribe($rootScope.channel);
        $scope.unsubscribed = true
      }
      else if($scope.unsubscribed===true){
        Hot5.Connections.Pusher.subscribe($rootScope.channel);
        $scope.unsubscribed = false
      }

      if($scope.pageState==='new_search' && !response.hotels)
        return;

      Page.criteria = response.criteria;
      Page.info = response.info;

      $scope.zoom = response.info.zoom;
      $scope.search_results = response
      $scope.amenities = response.info.amenities;
      $scope.slug = Page.info.slug

      
      $rootScope.channel = Page.info.channel
      $rootScope.currency_symbol = Page.criteria.currency_symbol;

      Hot5.Connections.Pusher.changeChannel($rootScope.channel);

      updateSlider(response.info);

      toggleShowMore(false);

      if( $scope.search_results.hotels)
        $scope.search_results.hotels.length < Page.info.available_hotels ?  angular.element("#loadmore").show() : angular.element("#loadmore").hide();

      $scope.$broadcast('results-loaded');
    };

    $scope.loadMore = function(response){
      delete $routeParams.load_more
      if(response.hotels && response.hotels.length > 0)
      {
        $scope.search_results.hotels = response.hotels;
        toggleShowMore(false);
        if($scope.search_results.hotels.length >= response.info.available_hotels)
        {
          $("#loadmore").hide();    
        }
      }
      else
      {
        init();       
      }
    };

    var toggleShowMore = function(isLoading){
      if(isLoading)
      {    
        $("#loadmore").addClass("disabled");
        $("#loadmore i").show();
        $("#loadmore span").text("Loading...");
      }
      else
      {        
        $("#loadmore").removeClass("disabled");
        $("#loadmore i").hide();
        $("#loadmore span").text("Show More...");
      }
    };

    var updateSlider = function(info)
    {
      var slider = angular.element('#priceSlider')
      if(slider)
      {
        slider.ionRangeSlider("update", {
            min:  Math.round(25),
            max:  Math.round(info.max_price || 300),
            from: Math.round(info.min_price_filter || 25),               // change default FROM setting
            to:   Math.round(info.max_price_filter || (info.max_price || 300)),   // change default TO setting
        });
      } 
    };

    var applyFilter = function(){
      startUpdater();
      $routeParams.count = Page.info.page_size;
      $scope.search();
      $scope.$broadcast('filter-applied');
    };

    $scope.isSort = function(option){
      return option === Page.info.sort
    };

    $scope.providers = function(hotel){
      return _.sortBy(hotel.providers, function(provider){
        return provider.min_price;
      })
    };

    $scope.checkAmenity = function(hotel, amenityMask){
      if(hotel.amenities)
        return (amenityMask | hotel.amenities) === hotel.amenities
      return false;
    }

    $scope.findProvider = function(hotel, providerName){
      var providerResult =  _.find(hotel.providers, function(provider){ 
        return provider ? provider.provider === providerName : false;
      });
      return providerResult === undefined ? {min_price: 0} : providerResult
    };

    $scope.saving = function(hotel){
      return Math.floor( (1-(hotel.offer.min_price / hotel.offer.max_price))*100)
    };

    $scope.ratingsRange = function(rating){
      return _.range(0, rating)
    };

    $scope.getRooms = function(hotel) {

      if(hotel.rooms && hotel.rooms.length > 0)
        return;

      hotel.displayRooms = false

      var timeoutId = $timeout(function(){
        hotel.displayRooms = true
      }, 30000)

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

    $scope.showImage = function(e, image){
      return app.loadImage(e.srcElement, image.url);
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
      applyFilter();
    };

    $scope.headerImage = function(hotel){
      if(hotel.images.length>0){
        return hotel.images[0].url;
      }
      return 'http://d1pa4et5htdsls.cloudfront.net/images/61/2025/68208/68208-rev1-img1-400.jpg'
    };

    $scope.providerImage = function(provider){
      if(provider)
        return '/assets/logos/' + provider + '.gif'
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

      applyFilter();
    };

    $rootScope.filterAmenities = function (amenity) {
      var amenities = $scope.amenities || [];

      var idx = amenities.indexOf(amenity);
      if (idx > -1) 
        amenities.splice(idx, 1);
      else
        amenities.push(amenity);
      $routeParams.amenities = amenities.join(',');
      if($routeParams.amenities==='')
        delete $routeParams.amenities
      applyFilter();
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
      applyFilter();
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

      if($scope.slug==undefined)
        return;

      var params = {},
          qs  = $location.search(),
          url = '';

      if($scope.selectType)
        $routeParams.id = $scope.slug;
      else
        $routeParams.id = $location.path();

      if($scope.slug=='my-location')
      {
        app._onSearchSubmitGeo();
        return;
      }
      
      params.start_date = start_date();
      params.end_date = end_date();
      params.currency = Page.criteria.currency_code;

      if($scope.selectType=='hotel')
      {
        url = 'hotels/';
      }
      else
      {
        params.sort = $routeParams.sort;

        if(qs.hotel && !$scope.selectType)
          params.hotel = qs.hotel;
      }

      Hotels.removeEmptyKeys(params);
      url += $routeParams.id + '?' + $.param(params);
        
      window.location.href = url
    };

   $scope.locationSelect = function (query, slug, type) {
      $scope.selectType = type;
      $scope.slug = slug;
      Page.info.slug = slug;
    };

    $rootScope.loadMoreClick = function() {
      toggleShowMore(true);
      $routeParams.count += Page.info.page_size;
      $routeParams.load_more = true;
      $scope.search($scope.loadMore);
      return false;
    };

    $scope.getGoogleMapCenter = function(){
      return new google.maps.LatLng(Page.info.latitude, Page.info.longitude)
    }

    $scope.hotelLocations = function(){
     return  $scope.search_results.hotels;
    }


    $scope.queryMap = function(mapCenter, callback){
      var url     = '/map/my-location',
          params  = $scope.buildParams();

      params.count = 101;
      params.coordinates = mapCenter.lat() + ',' + mapCenter.lng();

      $http.get(url, {
        headers:{'Accept':"application/json"}, 
        params:params
      }).success(callback)
    }

    $scope.trackClick = function(clickDetails){
      var params = $scope.buildParams();
     
      var url = '/offer/' + clickDetails.provider + '?';
      params.price = clickDetails.price;
      params.max_price = clickDetails.max_price;
      params.saving = clickDetails.saving;
      params.hotel_id = clickDetails.hotel_id;
      params.target_url = clickDetails.url;
      Hotels.removeEmptyKeys(params)
      var result = decodeURIComponent($.param(params));
      window.open(url + result);
    }
    
    $scope.ratingsText = Hotels.ratingsText; 


  var init = function(){
    startLoader();
    $routeParams.page_no = 1;
    var slider = angular.element('#priceSlider')

    slider.ionRangeSlider({
      type: 'double', 
      prefix: '£',
      hideMinMax: true,
      hideFromTo: true,
      min: 25,
      from: 25,
      to: 300,
      step: 5,
      onFinish: Hotels.priceRange.change
    })

    initTimeoutId = $timeout(function() {
      $scope.search()                 
    }, 2500);

    $timeout(function() {
      Hot5.Connections.Pusher.unsubscribe($rootScope.channel);
      $scope.unsubscribed = true                
    }, 45000);
  };

  init();
  


}]);


