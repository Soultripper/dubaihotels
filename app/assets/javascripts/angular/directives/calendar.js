app.directive('checkin', ['$filter', function($filter) {
  return {
    // require: 'ngModel',
    link: function(scope, el, attr) {

      var checkin = $(el).datepicker({
            startDate: "today",
            endDate: "+1y",
            format: "D dd M",
            todayHighlight: true,
            autoclose: true,
            orientation: "top auto"
        }).on('changeDate', function(ev) {  
          end_date = ev.date;
          end_date.setDate(end_date.getDate() + 1)
          angular.element('#end_date').datepicker('update', end_date)
          scope.$apply(function() {
            scope.start_date = $filter('date')(ev.date, 'yyyy-MM-dd');            
            angular.element('#end_date').datepicker('show')
          })
        }).data('datepicker');
      }
    }
  }]);

app.directive('checkout', ['$filter', function($filter) {
  return {
    // require: 'ngModel',
    link: function(scope, el, attr) {

      var checkout = $(el).datepicker({
          startDate: "+1d",
          endDate: "+1y",
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
            scope.end_date = $filter('date')(ev.date, 'yyyy-MM-dd');
            // ngModel.$setViewValue(date);
          })
        }).data('datepicker');
      }
    }
  }]);