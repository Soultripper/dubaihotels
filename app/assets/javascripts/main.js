var HI = function(){
  
  var mapOptions = {
    zoom: 15,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var stars = {
    select: function(){
      $(this).prevAll().addClass('checked');
      $(this).nextAll().removeClass('checked');
      $(this).addClass('checked');
      window.location = updateQueryStringParameter(window.location.href, 'max_stars', $(this).data('stars'));
    }
  };

  var photos = {
    displayMain: function(){
      var main = $(this).closest('.hotel_info_content').find('.hotel_info_image img');
      console.log($(main).attr('id'))
      $(main).css('background-image', "url(" + $(this).data('main') + ")")
    }
  };

  var sorter = {
    sort: function(){
    }
  };

  var map ={
    options: function(){

    },
    show: function(){
      var $self = $(this); 
      var $mapContainer = $('#' + $self.data('map'));
      var loaded        = $self.data('map-loaded');

      $mapContainer.slideToggle(function(){
        if(!loaded)
        {
          var lat = $mapContainer.data('lat');
          var lng = $mapContainer.data('lng');
          var mapCenter = {center: new google.maps.LatLng(lat, lng)};   
          var map = new google.maps.Map(document.getElementById('google-' + $self.data('map')), $.extend( mapCenter, HI.mapOptions ));
          var marker = new google.maps.Marker({
              position: mapCenter.center,
              map: map
          });  
          $self.data('map-loaded', true)
        } 
      });      
    }
  };

  var rooms = {
    retrieve: function(){
      var $self = $(this); 
      var $roomsContainer = $($self.data('container'));
      var loaded        = $self.data('map-loaded');  
      $roomsContainer.slideToggle();   
      if(!loaded) 
      {
        $.get($(this).data('url'), function(data){
          $roomsContainer.html(data)
          $self.data('loaded', true)
        })
      }
    }
  };

  var amenities = function(){
  };

  return {
    stars: stars,
    photos: photos,
    sorter: sorter,
    map: map,
    rooms: rooms,
    mapOptions: mapOptions
  }
}();