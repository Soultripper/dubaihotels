$(function(){
  $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd' });

  // $("[date-picker]").datepicker({
  //   inline: false,
  //   //nextText: '&rarr;',
  //   //prevText: '&larr;',
  //   showAnim: 'drop',
  //   showOtherMonths: false,
  //   numberOfMonths: 1,
  //   minDate: new Date(),
  //   //dateFormat: 'dd MM yy',
  //   dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],        
  //   beforeShowDay: function(date) {
  //     var date1 = $.datepicker.parseDate("yy-mm-dd", $("#start_date").val());
  //     var date2 = $.datepicker.parseDate("yy-mm-dd", $("#end_date").val());
  //     return [true, date1 && ((date.getTime() == date1.getTime()) || (date2 && date >= date1 && date <= date2)) ? "dp-highlight" : ""];
  //   },
  //   onSelect: function(dateText, inst) {
  //       var date1 = $.datepicker.parseDate("yy-mm-dd", $("#start_date").val());
  //       var date2 = $.datepicker.parseDate("yy-mm-dd", $("#end_date").val());

  //       if (!date1 || date2) {
  //         $("#start_date").val(dateText);
  //         $("#end_date").val("");
  //         $(this).datepicker("option", "minDate", dateText);
  //       } else {
  //         $("#end_date").val(dateText);
  //         $(this).datepicker("option", "minDate", new Date());
  //       }
  //     }
  // });      

  $("[date-picker]").datepicker({
    inline: false,
    showAnim: 'fadeIn',
    showOtherMonths: false,
    numberOfMonths: 1,    
    minDate: new Date(),
    dateFormat: 'dd MM yy',
    dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  })

  $(document).on('click', '#js_locale_currency_selector', function(){$('#js_toolbar_localization').toggle()});
  $(document).on('click', 'li.js_cAjax', function(){
    var currency = $(this).data('currency')
    $('#currency').val(currency)
    $('#js_toolbar_localization').hide()
  });

  $(document).on('click', '.calendar_date_button', function(){$('#datepicker').slideToggle()});
  $(document).on('click', '.sbHolder', function(){$('#js_itemlistcontrol_sort').slideToggle()});
  $(document).on('click', 'li[data-link]', function(){window.location = $(this).data('link')});
  // $(document).on('click', 'ul li.stars', HI.stars.select);

  $('.hotel').on('click', '[data-slide-toggle]', function(){ $($(this).data('slide-toggle')).slideToggle()});
  $('.hotel').on('click', '[data-show-toggle]', function(){ $($(this).data('show-toggle')).toggleClass('open')});

  $('.hotel_info_thumbs img').hover(HI.photos.displayMain);
  $('.hotel').on('click', '.map', HI.map.show);
  $('.hotel').on('click', '[data-retrieve-rooms]', HI.rooms.retrieve);

  $("#priceSlider").ionRangeSlider();

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

 