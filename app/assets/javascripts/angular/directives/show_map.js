app.directive('showMap', ['$filter','$timeout', function($filter, $timeout) {
  return function( scope, element, attrs) 
  {

    var map, infowindow;
    var markers = [];
    var bound = false;
    

    element.bind('click', function(){
      if(!bound)
      {
        scope.$on('results-loaded', loadMarkers);
        bound = true;
      }

      $(document.body).addClass("map-showing");
      var location = scope.getGoogleMapCenter(); 
      var mapOptions = {
          center: location,
          zoom: scope.zoom+3,
          mapTypeControl: true,
          zoomControl: true,
          zoomControlOptions: {
            style:google.maps.ZoomControlStyle.SMALL,
            position: google.maps.ControlPosition.BOTTOM_RIGHT
          },
          mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      map = new google.maps.Map($("#map-container")[0], mapOptions);
      
     
      // map.panBy(0, 30);

      google.maps.event.addListener(map, "bounds_changed", function() {
        console.log("map bounds "+map.getBounds());
      });


      infowindow = new google.maps.InfoWindow({
        content: "<i class='fa fa-gear fa-spin'></i>"
      });

      loadMarkers();
    });

    function loadMarkers(){
      clearMarkers();
      drawMarkers(scope.hotelLocations());
      loadHotels(map);
    }

    function drawMarkers(hotels)
    {
      if(!$(document.body).hasClass("map-showing"))
        return;

      _.each(hotels, function(hotel){
        createMarker(hotel);
      })         
      // setAllMap(map)
    }

    function loadHotels(map){
      scope.queryMap(map, plotHotels);
    }

    function plotHotels(response){
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
     drawMarkers(hotels);
     // map.fitBounds(map.getBounds());
    }

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

      markers.push(marker);
      return marker;
    }

    function setAllMap(mapOwner) {
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(mapOwner);
      }
    }

    function clearMarkers() {
      setAllMap(null);
    }

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
    }

  }
}]);
