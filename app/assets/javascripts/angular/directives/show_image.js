app.directive( 'showImage', ['$location', '$window', function($location, $window) {
  return function ( scope, element, attrs ) {
    var url;

    attrs.$observe( 'showImage', function (image_url) {
      url = image_url;
    });

    element.bind( 'click', function () {
      var container = $(element).parents(".tab-gallery");
      var photoContainer = $(container).find(".photo");
      $("img", photoContainer).css("visibility", "hidden");
      $("ul.thumbs li", container).removeClass("active");
      $(element).parent().addClass("active");
      var image = new Image();
      image.src = url;
      $(image).load(function () {
          $("img", container).remove();
          $(photoContainer).append(image);
      });
      return false;
    });
  };
}]);