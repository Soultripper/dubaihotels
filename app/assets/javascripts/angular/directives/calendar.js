app.directive('checkin', ['$filter', function($filter) {
  return {
    require: 'ngModel',
    link: function(scope, el, attr, ngModel) {

      var checkin = $(el).datepicker({
            startDate: "today",
            endDate: "+2m",
            format: "D dd M",
            todayHighlight: true,
            autoclose: true,
            orientation: "top auto"
        }).on('changeDate', function(ev) {  
          scope.$apply(function() {
            var date = $filter('date')(ev.date, 'yyyy-MM-dd')
            ngModel.$setViewValue(date);
            angular.element('#end_date').datepicker('show')
          })
        }).data('datepicker');
      }
    }
  }]);

app.directive('checkout', ['$filter', function($filter) {
  return {
    require: 'ngModel',
    link: function(scope, el, attr, ngModel) {

      var checkout = $(el).datepicker({
          startDate: "today",
          endDate: "+2m",
          format: "D dd M",
          todayHighlight: true,
          autoclose: true,
          orientation: "top auto",     
          beforeShowDay: function(date){
            var checkin = angular.element('#start_date').datepicker('getDate')
            return date.valueOf() <= checkin.valueOf() ? 'disabled' : '';
          }      
        }).on('changeDate', function(ev) {        
          checkout.hide();
          scope.$apply(function() {
            var date = $filter('date')(ev.date, 'yyyy-MM-dd')
            ngModel.$setViewValue(date);
          })
        }).data('datepicker');
      }
    }
  }]);