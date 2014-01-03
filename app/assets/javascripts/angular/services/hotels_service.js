var hotelsServices = angular.module('hotelsServices', ['ngResource']);

hotelsServices.factory('HotelFactory', function() {

  return function(hotel){

    var hotel = this.hotel;

    var providers = function(){
      hotel.providers
    }

  }
});
