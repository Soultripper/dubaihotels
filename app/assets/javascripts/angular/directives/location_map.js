// app.directive( 'locationMap', function() {
//   return {
//     restrict: 'E',
//     transclude: false,
//     link: function(scope, element, attrs) {
//       var lat, lng

//       attrs.$observe( 'longitude', function (val) {lng = val});
//       attrs.$observe( 'latitude', function (val) {lat = val});


//       var mapOptions = {
//         zoom: 15,
//         mapTypeId: google.maps.MapTypeId.ROADMAP
//       };

//       var mapCenter = {center: new google.maps.LatLng(lat, lng)};   
      
//       var map = new google.maps.Map(element, $.extend( mapCenter, mapOptions ));

//       var marker = new google.maps.Marker({
//           position: mapCenter.center,
//           map: map
//       });  
//     }
//   }
// });