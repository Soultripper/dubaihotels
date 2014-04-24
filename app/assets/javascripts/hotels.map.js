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

  return {
    createMarker: createMarker
  };


}();

  