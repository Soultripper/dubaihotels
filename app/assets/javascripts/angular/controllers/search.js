
app.controller('SearchCtrl', ['$scope', '$http', '$location', '$window', '$filter',  
  function ($scope, $http, $location, $window, $filter) { 

    var end_date = function(){
      var date = angular.element('#end_date').datepicker('getDate')
      return $filter('date')(date, 'yyyy-MM-dd')
    }

    var start_date = function(){
      var date = angular.element('#start_date').datepicker('getDate')
      return $filter('date')(date, 'yyyy-MM-dd')
    }    

    $scope.cities = function(cityName) {
      return $http.get("/locations.json?query="+cityName).then(function(response){
        return response.data;
      });
    };

   $scope.citySelect = function (query, slug) {
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
      var location = $location.search(routes).path($scope.slug);
      window.location.href =  location.url()
    }

  }
])