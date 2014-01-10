
app.controller('SearchCtrl', ['$scope', '$http', '$location', '$window', '$filter', '$rootScope',  
  function ($scope, $http, $location, $window, $filter, $rootScope) { 

    var start_date = function(){
      var date = $scope.start_date
      return $filter('date')(date, 'yyyy-MM-dd')
    }    


    var end_date = function(){
       var date = $scope.end_date
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
      if($scope.slug===undefined)
        return;
      var routes = {
        start_date: start_date(),
        end_date: end_date()
      } 

      if(routes.start_date && routes.end_date)
        window.location.href =  '/' + $scope.slug + '?start_date=' + routes.start_date + '&end_date=' + routes.end_date
      else
        window.location.href =  '/' + $scope.slug 
      // var location = $location.path($scope.slug).search(routes);
      
    }

  }
])