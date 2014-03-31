app.directive('showMap', ['$filter','$timeout', function($filter, $timeout) {
  return function( scope, element, attrs) 
  {
    element.bind( 'click', function () {
      $(document.body).addClass("map-showing");
      angular.element("#map-loader").show();

      // Get map data....
      $timeout(function () {
          angular.element("#map-loader").hide();
          var location = scope.getGoogleMapCenter(); //new google.maps.LatLng(-34.397, 150.644);
          var mapOptions = {
              center: location,
              zoom: scope.zoom+4
          };

          var map = new google.maps.Map($("#map-container")[0], mapOptions);
          map.panBy(0, 30);

          var infowindow = new google.maps.InfoWindow({
              content: "<i class='fa fa-gear fa-spin'></i>"
          });

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
              return marker;
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
          _.each(scope.hotelLocations(), function(hotel){
            createMarker(hotel);
          })
      }, 1000);
    });
  }
}]);
