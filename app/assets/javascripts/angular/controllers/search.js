
app.controller('SearchCtrl', ['$scope', '$http', '$location', '$window', '$filter', '$rootScope',  
  function ($scope, $http, $location, $window, $filter, $rootScope) { 

    var start_date = function(){
      var format = 'yyyy-mm-dd';
      return angular.element("#start_date").data('datepicker').getFormattedDate(format);

      // var date = $scope.start_date
      // return $filter('date')(date, 'yyyy-MM-dd')
    }    


    var end_date = function(){
      var format = 'yyyy-mm-dd';
      return angular.element("#end_date").data('datepicker').getFormattedDate(format);
    }


    $scope.cities = function(cityName) {
      return $http.get("/locations.json?query="+cityName).then(function(response){
        return response.data;
      });
    };

   $scope.locationSelect = function (query, slug, type) {
      $scope.selectType = type;
      $scope.slug = slug
    };

   // $scope.citySelect = function ($item, $model, $label) {
   //    Page.info().query = $item.n
   //    Page.info().slug = $item.s
   //  };
    $scope.search = function(){

      var routes = {
        start_date: start_date(),
        end_date: end_date()
      } 

      var url = '';

      if($scope.slug===undefined)
        return;

      if($scope.selectType=='hotel')
        $scope.slug = 'hotels/' + $scope.slug 

      url =  '/' + $scope.slug

      if(routes.start_date || routes.end_date)
      {
        url += '?'

        if(routes.start_date)
          url += 'start_date=' + routes.start_date + '&'

        if(routes.end_date)
          url += 'end_date=' + routes.end_date
      }
      
      window.location.href = url

      // var location = $location.path($scope.slug).search(routes);
      
    }

  }
])