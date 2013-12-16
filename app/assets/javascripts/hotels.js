var Hotels = function(){
  
  var init = function(){
    $("#priceSlider").ionRangeSlider(
      {
        type: 'double', 
        prefix: '£',
        step: 5,
        onFinish: Hotels.priceRange.change
      });

    $('#search-input').soulmate({
      url:            'http://' + Hotels.searchOptions.domain + '/sm/search',
      types:          ['landmark', 'city', 'region', 'country'],
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
          scope.citySelect(term, data.slug || data.url)
        })
        $('#soulmate').hide();
      },
      minQueryLength: Hotels.searchOptions.minQueryLength,
      maxResults:     Hotels.searchOptions.maxResults
    });

  }


  var searchOptions ={
    domain: 'localhost:9292',
    minQueryLength: 2,
    maxResults:     5    
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



  return {
    init: init,
    stars: stars,
    priceRange: priceRange,
    searchOptions: searchOptions
  }
}();