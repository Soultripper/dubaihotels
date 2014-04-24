var Hotels = function(){
  
  var searchOptions ={
    domain: 'www.hot5.com',
    //domain: 'localhost:5000',
    minQueryLength: 2,
    maxResults:     7    
  }

  var init = function(){
    // $("#priceSlider").ionRangeSlider(
    //   {
    //     type: 'double', 
    //     prefix: '£',
    //     step: 5,
    //     onFinish: Hotels.priceRange.change
    //   });

    $('#search-input').soulmate({
      url:            'http://' + Hotels.searchOptions.domain + '/sm/search',
      types:          ['city', 'region', 'country', 'hotel', 'place', 'landmark'],
      renderCallback: function(term, data, type){ return data.title; },
      selectCallback: function(term, data, type){ 
        var scope, el;
        el = angular.element($("#hotel-results"));
        if(el.length===0)
          el = angular.element($("#search-input"))

        var scope = el.scope();
        // var rootScope = scope.$root;
        scope.$apply(function(){
          $('#search-input').val(data.title)
          scope.locationSelect(term, data.slug, type)
        })
        $('#soulmate').hide();
      },
      minQueryLength: Hotels.searchOptions.minQueryLength,
      maxResults:     Hotels.searchOptions.maxResults
    });

  }




  var priceRange = {
    change: function(priceSlider){
      var scope = angular.element($("#hotel-results")).scope();
      scope.safeApply(function(){
        scope.changePrice(priceSlider.fromNumber,priceSlider.toNumber)
      });
    }
  }


  var stars = {
    select: function(){
      $(this).prevAll().addClass('checked');
      $(this).nextAll().removeClass('checked');
      $(this).addClass('checked');
      window.location = updateQueryStringParameter(window.location.href, 'max_stars', $(this).data('stars'));
    }
  };


  // var rooms = {
  //   retrieve: function(){
  //     var $self = $(this); 
  //     var $roomsContainer = $($self.data('container'));
  //     var loaded        = $self.data('map-loaded');  
  //     $roomsContainer.slideToggle();   
  //     if(!loaded) 
  //     {
  //       $.get($(this).data('url'), function(data){
  //         $roomsContainer.html(data)
  //         $self.data('loaded', true)
  //       })
  //     }
  //   }
  // };



  var amenities = function(){
  };

  var getDescription =  function(hotelProvider){
   switch(hotelProvider){
     case 'booking':
       return "Booking.com";
     case 'expedia':
       return "Expedia.co.uk";
     case 'agoda':
       return 'Agoda.com';
     case 'easy_to_book':
       return 'EasyToBook.com';
     case 'splendia':
       return 'Splendia.com';
     // case 'hotels':
     //   return 'Hotels.com';       
     case 'laterooms':
       return 'LateRooms.com';  
     case 'venere':
       return 'Venere.com';           
     default:
       return hotelProvider; 
     }
   };

  
  var removeEmptyKeys = function(obj){
    Object.keys(obj).forEach(function(k) {
        if (!obj[k]) delete obj[k];
      }
    );
  };

  var ratingsText = function(rating_percentage){
    if(rating_percentage > 90)
      return "HOT";
    if(rating_percentage > 80)
      return "Excellent";
    else if(rating_percentage > 70)
      return "Great";
    else if(rating_percentage > 60)
      return "Good";
    else if(rating_percentage > 40) 
      return "Average";
    else
      return "Poor"
  }

  return {
    init: init,
    stars: stars,
    priceRange: priceRange,
    searchOptions: searchOptions,
    description: getDescription,
    removeEmptyKeys: removeEmptyKeys,
    ratingsText: ratingsText
  }
}();