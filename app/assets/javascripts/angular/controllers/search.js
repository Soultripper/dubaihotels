
app.controller('SearchCtrl', ['$scope', '$http', '$location', '$window',  
  function ($scope, $http, $location, $window) { 

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
        start_date: $scope.start_date,
        end_date: $scope.end_date
      } 
      var location = $location.search(routes).path($scope.slug);
      $window.location.href =  location.url()
    }

  }
])