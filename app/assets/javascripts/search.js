

$(function(){
  $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd' });
   
  $("[calendar]").datepicker({
    inline: false,
    showAnim: 'fadeIn',
    showOtherMonths: false,
    numberOfMonths: 1,    
    minDate: new Date(),
    dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  })

  HI.init();


  var pull        = $('#pull');
      menu        = $('.refine');
      menuHeight  = menu.height();

  $(pull).on('click', function(e) {
    e.preventDefault();
    menu.slideToggle();
  });

  $(window).resize(function(){
    var w = $(window).width();
    if(w > 768 && menu.is(':hidden')) {
      menu.removeAttr('style');
    }
  });
  

  $("#priceSlider").ionRangeSlider(
    {
      type: 'double', 
      prefix: '£',
      step: 5,
      onFinish: HI.priceRange.change
    });

  // $( "#slider-range" ).rangeSlider({
  //   bounds:{
  //     min: 35,
  //     max: 1500
  //   }
  // });
  
  // $( "#amount" ).val( "£" + $( "#slider-range" ).slider( "values", 0 ) + " - £" + $( "#slider-range" ).slider( "values", 1 ) );


});

function updateQueryStringParameter(uri, key, value) {
  var re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i");
  separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + "=" + value + '$2');
  }
  else {
    return uri + separator + key + "=" + value;
  }
}

 