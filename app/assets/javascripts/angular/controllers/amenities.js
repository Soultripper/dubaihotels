app.controller('AmenitiesCtrl', ['$scope', function AmenitiesCtrl($scope) {

  // selected fruits
  $scope.amenities = [];

  // toggle selection for a given fruit by name
  $scope.filterAmenities = function toggleSelection(amenity) {
    var idx = $scope.amenities.indexOf(amenity);
    if (idx > -1) 
      $scope.amenities.splice(idx, 1);
    else
      $scope.amenities.push(amenity);
  };
}]);