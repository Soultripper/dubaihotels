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


  // $(document).on('click', 'ul li.stars', HI.stars.select);


  $("#priceSlider").ionRangeSlider();

  HI.init();
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

 