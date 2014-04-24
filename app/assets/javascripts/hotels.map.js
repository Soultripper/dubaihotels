Hotels.Map = function(){

  var createMarker = function createMarker(details) {
    var marker = new google.maps.Marker({
        position: new google.maps.LatLng(details.latitude, details.longitude),
        icon: "/assets/icons/map-marker.png",
        title: details.name,
    });

    if(details.map)
      marker.setMap(details.map);
    return marker;
  }

  var createFixedMap = function(elementId, lat, lng, options){

      options = options || {};

      var mapOptions = {
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false,
        draggable: options['draggable'],
        disableDefaultUI: true
      };

      mapOptions['zoom'] = options['zoom'] || 14;
      
      var container = document.getElementById(elementId)
      var mapCenter = {center: new google.maps.LatLng(lat, lng)};  
      var map = new google.maps.Map(container, $.extend( mapCenter, mapOptions ));
      return map;
    }

  return {
    createMarker: createMarker,
    createFixedMap: createFixedMap
  };


}();

  