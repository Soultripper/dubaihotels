app.directive('showMap', ['$filter','$timeout', '$interval', function($filter, $timeout, $interval) {
  return function( scope, element, attrs) 
  {

    var map, infowindow, centerMarker;
    var markersPrimary   = [],
        markersSecondary = [],
        bound = false,
        searchingTimerId;

    var myPin = new google.maps.MarkerImage("http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=|00FF00|000000");


    function addEventListeners(){
      if(!bound){
        scope.$on('results-loaded', loadMarkers);
        scope.$on('filter-applied', function(){
          setAllMap(markersSecondary, null)
          markersSecondary =[]
          setAllMap(markersPrimary, null)
          // markersSecondary =[]
          loadHotels();
        });
        bound = true;
      }
    }

    element.bind('click', function(){

      addEventListeners();
      $(document.body).addClass("map-showing");

      var location = scope.getGoogleMapCenter(); 

      var mapOptions = {
          center: location,
          zoom: scope.zoom+2,
          mapTypeControl: true,
          zoomControl: true,
          zoomControlOptions: {
            style:google.maps.ZoomControlStyle.SMALL,
            position: google.maps.ControlPosition.BOTTOM_RIGHT
          },
          mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      map = new google.maps.Map($("#map-container")[0], mapOptions);

      plotCenter();

      google.maps.event.addListener(map, "idle", function() {
        $timeout(plotNewCoordinates, 1000)
      });

      infowindow = new google.maps.InfoWindow({
        content: "<i class='fa fa-gear fa-spin'></i>"
      });

      loadMarkers();
    });

    function plotCenter(){
      centerMarker = new google.maps.Marker({
          position: map.getCenter(),
          map: map,
          icon: myPin,
          title: 'Center'
        })
    };

    function loadMarkers(){
      setAllMap(markersPrimary, null);
      markersPrimary = [];
      drawMarkers(scope.hotelLocations(), markersPrimary);
      // loadHotels();
    };

    function drawMarkers(hotels, markerArray)
    {

      if(!$(document.body).hasClass("map-showing"))
        return;

      _.each(hotels, function(hotel){
        markerArray.push(createMarker(hotel));
      })         
      // console.log('After drawing markers: ' + markerArray.length)
    };

    function createMarker(hotel) {
      var marker = new google.maps.Marker({
          position: new google.maps.LatLng(hotel.latitude, hotel.longitude),
          map: map,
          title: hotel.name,
          image: hotel.image,
          rating: hotel.star_rating,
          price: hotel.price,
          deal: hotel.deal,
          slug: hotel.slug
      });

      google.maps.event.addListener(marker, 'click', showInfo);
      google.maps.event.addListener(marker, 'mouseover', showInfo);
      return marker;
    };

    function loadHotels(){
      var center = map.getCenter();
      // markersSecondary = []
      scope.queryMap(center, plotHotels);
    };

    function plotNewCoordinates(){
      centerMarker.setMap(null);

      console.log('Map is now idle: ' + map.getCenter());

      plotCenter();

      loadHotels(map);

      searchingTimerId = $interval(function() {
        loadHotels(map);
      }, 2000, 5);
    };


    function plotHotels(response){
      if(response.state==='finished')
        $interval.cancel(searchingTimerId);

     var hotels = _.map(response.hotels, function(hotel){
        return {
          'name': hotel.name,
          'latitude': hotel.latitude,
          'longitude': hotel.longitude,
          'star_rating': hotel.star_rating,
          'price': accounting.formatMoney(hotel.offer.min_price, scope.currency_symbol, 0),
          'deal': hotel.offer.link,
          'image': scope.headerImage(hotel),
          'slug': hotel.slug,
        };
      });

     
     drawMarkers(hotels, markersSecondary);
     // map.fitBounds(map.getBounds());
    };


    function setAllMap(markers, mapOwner) {
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(mapOwner);
      }
    };

    function showInfo() {
        var infoHtml = $("<div class='map-marker-info'><div class='image'></div><div class='info'><h3>...</h3><div class='rating'></div><div class='price'></div></div><div class='buttons'><a href='#' class='btn btn-success get-deal' target='_blank'>Get Deal</a><a href='#' class='btn btn-primary more-info' target='_self'>More Info</a></div></div>");
        $(".image", infoHtml).css("background-image", "url(" + this.image + ")");
        $("h3", infoHtml).text(this.title);
        $(".rating", infoHtml).empty();
        $(".price", infoHtml).text(this.price);
        $(".get-deal", infoHtml).attr("href", this.deal);
        $(".more-info", infoHtml).attr("href", '/hotels/'+this.slug);

        for (var i = 1; i <= 5; i++) {
          var starClass = "fa-star";
          if (i > this.rating)
              starClass = "fa-star-o";                
          $(".rating", infoHtml).append("<i class='fa " + starClass + "'></i>");
        }

        infowindow.setContent(infoHtml.prop('outerHTML'));
        infowindow.open(map, this);
    };

  }
}]);
