app.filter('price', function() {
  return function(value, symbol, precision) {
    if(value <= 0 || value==undefined) return "sold out";

    return accounting.formatMoney(value, symbol, precision);
  };
});