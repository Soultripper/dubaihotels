
app.controller('HotelsCtrl', ['$scope', '$rootScope', '$http', '$routeParams', '$timeout', '$location', '$filter', 'HotelResults', 'HotelRooms', 'Page', 'HotelProvider','HotelFactory', '$log', 
  function ($scope, $rootScope, $http, $routeParams, $timeout, $location, $filter, HotelResults, HotelRooms, Page, HotelProvider, HotelFactory, $log) { 

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
      params.key          = Page.info.key
      return params;
    };

    $scope.buildRoomParams = function(hotel){
      var params = {};

      params.start_date   = start_date();
      params.end_date     = end_date();
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
      qs.push('&key='        + Page.info.key)
      return qs.join('')
    };

    // $scope.trackClick = function(clickDetails){
    //   var params = $scope.buildParams();
     
    //   var url = '/offer/' + clickDetails.provider + '?';
    //   params.price = clickDetails.price;
    //   params.max_price = clickDetails.max_price;
    //   params.saving = clickDetails.saving;
    //   params.hotel_id = clickDetails.hotel_id;
    //   //params.target_url = clickDetails.url;
    //   Hotels.removeEmptyKeys(params)
    //   var result = decodeURIComponent($.param(params));
    //   window.open(url + result);
    // }

    // $scope.offerLink = function(hotel, provider){
    //   var qs = [];
    //   qs.push('/offer/');
    //   qs.push(provider.provider );
    //   qs.push('?price='     + provider.min_price);
    //   qs.push('&max_price=' + provider.max_price);
    //   qs.push('&saving='    + $scope.saving(hotel));
    //   qs.push('&hotel_id='  + hotel.id);
    //   return qs.join('')
    // };

    $scope.initPage = function(initData){

      $scope.start_date = initData.criteria.start_date;
      $scope.end_date = initData.criteria.end_date;
      
      angular.element('#search-input').val('')
      angular.element('#start_date').datepicker('update', new Date(Date.parse($scope.start_date)));
      angular.element('#end_date').datepicker('update', new Date(Date.parse($scope.end_date)));

      if(initData.state!="invalid")
        Hotels.Map.createFixedMap('location-map', initData.info.latitude, initData.info.longitude, {zoom: initData.info.zoom, draggable: false});


      $scope.setupPage(initData)
    };

    $scope.setupPage = function(response){

      stopUpdater();

      $scope.pageState = response.state;
      
      if($scope.pageState==='finished' || $scope.pageState==='invalid')
      {
        $timeout.cancel(initTimeoutId);
        stopLoader();
        Hot5.Connections.Pusher.unsubscribe($rootScope.channel);
        $scope.unsubscribed = true
      }
      else if($scope.unsubscribed===true){
        Hot5.Connections.Pusher.subscribe($rootScope.channel);
        $scope.unsubscribed = false
      }

      $routeParams.count = response.info.page_size;

      Page.criteria = response.criteria;
      Page.info = response.info;

      $rootScope.currency_symbol = Page.criteria.currency_symbol;

      updateSlider(response.info);

      if(($scope.pageState==='new_search' && !response.hotels) || $scope.pageState==='invalid')
        return;

      $scope.zoom = response.info.zoom;
      $scope.search_results = response
      $scope.amenities = response.info.amenities;
      $scope.slug = Page.info.slug

      $rootScope.channel = Page.info.channel

      Hot5.Connections.Pusher.changeChannel($rootScope.channel);

      

      toggleShowMore(false);

      if( $scope.search_results.hotels)
        $scope.search_results.hotels.length < Page.info.available_hotels ?  angular.element("#loadmore").show() : angular.element("#loadmore").hide();

      $scope.$broadcast('results-loaded');
    };

    $scope.search = function(callback) {
      if(!callback)
        callback = $scope.setupPage;

      var params = $scope.buildParams();
      HotelResults.get($location.path(), params).success(callback)
    };


    $scope.changeCurrency = function(currency){
      Page.criteria.currency_code = currency;
      $scope.currency = currency;
      $rootScope.searchCity()
    };

    $scope.getRooms = function(obj, hotel) {
      app.tabSelect(obj.target, 'rooms');
      if(hotel.rooms && hotel.rooms.length > 0)
        return;
      roomsQuery(hotel, timeoutId, obj)
    };

    var roomsQuery = function(hotel, timeoutId, obj){
      var params = {'key': Page.info.key }

      hotel.loadingRooms = true;
      HotelResults.get('/hotels/' + hotel.slug + '/rooms', params).success(
        function(response){

          hotel.rooms = response           
          $timeout(function(){
            hotel.loadingRooms = false;
            }, 50) 
         
        });
    };

    $scope.getImages = function(obj, hotel) {
      app.tabSelect(obj.target, 'gallery');
      if(hotel.images && hotel.images.length > 0)
        return;
      hotel.loadingImages = true;
      HotelResults.get('/hotels/' + hotel.slug).success(
        function(response){
          hotel.images = response.hotel.images;
          $timeout(function(){
            hotel.loadingImages = false;
            app._loadGallery($("#tab-gallery-" + hotel.id));
            }, 750) 
          
        });
    };


    $scope.loadMore = function(response){
      delete $routeParams.load_more
      var hotels = response.hotels;

      if(hotels && hotels.length > 0)
      {
        $scope.search_results.hotels = hotels;
        toggleShowMore(false);
        if((hotels.length >= response.info.available_hotels))
          $("#loadmore").hide();    
        if(hotels.length > 100){
          $("#loadmore").hide();  
          $("#nomore").hide();      
        }
      }
      else
      {
        init();       
      }
    };

    $rootScope.loadMoreClick = function() {
      toggleShowMore(true);
      $routeParams.count += Page.info.page_size;
      $routeParams.load_more = true;
      $scope.search($scope.loadMore);
      return false;
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
        $("#nomore").hide();    
      }
    };

    var updateSlider = function(info)
    {
      var slider = angular.element('#priceSlider')
      if(slider)
      {
        // console.log(info.price_values)
        // slider.ionRangeSlider("update",{
        //   values: info.price_values
        // })


        slider.ionRangeSlider("update", {
            min:  Math.round(25),
            max:  Math.round(info.max_price || 300),
            from: Math.round(info.min_price_filter || 25),               // change default FROM setting
            to:   Math.round(info.max_price_filter || (info.max_price || 300)), 
            prefix: $rootScope.currency_symbol
           // values: info.price_values  
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


    $scope.showImage = function(e, image){
      return app.loadImage(e.srcElement, image.url);
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
      //return (hotel.main_image && hotel.main_image.url) ? hotel.main_image.url :  'http://d1pa4et5htdsls.cloudfront.net/images/61/2025/68208/68208-rev1-img1-400.jpg'

      return (hotel.main_image && hotel.main_image.image_url) ? hotel.main_image.image_url :  'http://d1pa4et5htdsls.cloudfront.net/images/61/2025/68208/68208-rev1-img1-400.jpg'
    };

    $scope.formatPrice = function(price){
      return accounting.formatNumber(price,0);
    };

    $scope.providerImage = function(provider){
      if(provider)
        return '/assets/logos/' + provider + '.gif'
      return ''    
    };

    $rootScope.changePrice = function(min_price, max_price){

      $routeParams.min_price = min_price; //Page.info.price_values[min_price];
      $routeParams.max_price = max_price; ///Page.info.price_values[max_price];

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


    $scope.getGoogleMapCenter = function(){
      return new google.maps.LatLng(Page.info.latitude, Page.info.longitude)
    }

    $scope.hotelLocations = function(){
     return  $scope.search_results.hotels;
    }


    $scope.queryMap = function(mapCenter, callback){
      var url     = '/map/my-location',
          params  = $scope.buildParams();

      params.count = 51;
      params.coordinates = mapCenter.lat() + ',' + mapCenter.lng();

      HotelResults.get(url,params).success(callback)
    }

    $scope.trackClick = function(clickDetails){
      var params = $scope.buildParams();
     
      var url = '/offer/' + clickDetails.provider + '?';
      params.price = clickDetails.price;
      params.max_price = clickDetails.max_price;
      params.saving = clickDetails.saving;
      params.hotel_id = clickDetails.hotel_id;
      params.provider_id = clickDetails.provider_id;

      //params.target_url = clickDetails.url;
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
      hideMinMax: false,
      hideFromTo: false,
      min: 25,
      max: 300,
      from: 25,
      to: 300,
      step: 5,
      // values: _.range(1,100),
      onFinish: Hotels.priceRange.change
    })

    initTimeoutId = $timeout(function() {
      $scope.search()                 
    }, 6000);

    $timeout(function() {
      Hot5.Connections.Pusher.unsubscribe($rootScope.channel);
      $scope.unsubscribed = true                
    }, 45000);
  };

  init();
  


}]);


