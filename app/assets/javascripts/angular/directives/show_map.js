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

      var styles = [
         {
           featureType: "poi",
           stylers: [
            { visibility: "off" }
           ]   
          }
      ];

      map = new google.maps.Map($("#map-container")[0], mapOptions);
      map.setOptions({styles: styles});
      
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
      drawMarkers(scope.search_results.hotels, markersPrimary);
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
          icon: "assets/icons/map-marker.png",
          hotel: hotel
      });

      google.maps.event.addListener(marker, 'click', showInfo);
      // google.maps.event.addListener(marker, 'mouseover', showInfo);
      return marker;
    };

    function loadHotels(){
      var center = map.getCenter();
      // markersSecondary = []
      scope.queryMap(center, plotHotels);
    };

    function plotNewCoordinates(){
      centerMarker.setMap(null);
      plotCenter();
      loadHotels(map);
      searchingTimerId = $interval(function() {
        loadHotels(map);
      }, 2000, 5);
    };


    function plotHotels(response){
      if(response.state==='finished')
        $interval.cancel(searchingTimerId);
     
     drawMarkers(response.hotels, markersSecondary);
     // map.fitBounds(map.getBounds());
    };


    function setAllMap(markers, mapOwner) {
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(mapOwner);
      }
    };

    function showInfo() {
        resetMarkerIcons();

        var hotel = this.hotel;
        var hotel_image = scope.headerImage(hotel);

        this.setIcon("assets/icons/map-marker-s.png");
        this.setZIndex(google.maps.Marker.MAX_ZINDEX + 1);

        var infoHtml = $("#map-info-window").show();
        var params = scope.buildParams();

        Hotels.removeEmptyKeys(params);

        var getDeal = $(".get-deal", infoHtml);

        getDeal.data("get-deal", hotel.offer.link);
        getDeal.data("price", hotel.offer.min_price);
        getDeal.data("hotel-id", hotel.id);
        getDeal.data("provider", hotel.offer.provider);
        getDeal.data("max-price", hotel.offer.max_price);
        getDeal.data("saving", scope.saving(hotel));

        $(".image", infoHtml).css("background-image", "url(" + hotel_image + ")");
        $("h3", infoHtml).text(hotel.name);
        $(".rating", infoHtml).empty();
        $(".price", infoHtml).text(accounting.formatMoney(hotel.offer.min_price, scope.currency_symbol, 0));
        
        $(".more-info", infoHtml).attr("href", '/hotels/' + hotel.slug + '?' + $.param(params));

        for (var i = 1; i <= 5; i++) {
          var starClass = "fa-star";

          if (i > hotel.star_rating)
              starClass = "fa-star-o";
          
          $(".rating", infoHtml).append("<i class='fa " + starClass + "'></i>");
        }
    }

    function resetMarkerIcons() {
      var markers = markersPrimary.concat(markersSecondary);

      $(markers).each(function () {
          if (this.icon.indexOf("map-marker-s.png") == -1)
              return;

          this.setIcon("assets/icons/map-marker.png");
          this.setZIndex(google.maps.Marker.MAX_ZINDEX);
      });
    }

    $("#map-info-window").hide();
    $("#map-info-window .exit").on("click", function () {
        $("#map-info-window").hide();
        resetMarkerIcons();
    });
            

  }
}]);
