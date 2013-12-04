 app.directive("loadingIndicator", ['$timeout', function($timeout) {
        var tuttimer;

        return {
            restrict : "E",
            templateUrl: "templates/loader.html",
            link : function(scope, element, attrs) {
              var timeoutId
              tuttimer = [];
              scope.$on("loading-started", function(e) {
                // console.log('loading-started')
 
                $("#results .loader .progress-bar").width("0%");

                timeoutId = $timeout(function() {                  
                  $(".loader", element).fadeIn('fast');
                  $(".overlay",element).fadeIn('fast');

                  var total = 10;
                  _(total).times(function(i){

                    var timeout = i * 500;

                    tuttimer.push($timeout(function() {
                        var percent = ((i + 1) / total) * 100;
                        $("#results .loader .progress-bar").width(percent + "%");

                        if (i+1==total) {
                          $timeout(function () {
                            $(".overlay",element).fadeOut('fast');
                            $(".loader", element).fadeOut('fast'); 
                          }, 500);
                        }
                    }, timeout))
                  })
                }, 1000);
               
              });

              scope.$on("loading-complete", function(e) {
                // console.log('loading-complete')
                $timeout.cancel(timeoutId);
                for (var i = 0; i < tuttimer.length; i++) {
                  $timeout.cancel(tuttimer[i])
                }
                
                // $("#results .loader .progress-bar").width("100%");
                $timeout(function() {
                  $(".overlay",element).fadeOut('fast');
                  $(".loader", element).fadeOut('fast');                    
                }, 500);
              });

            }
        };
    });