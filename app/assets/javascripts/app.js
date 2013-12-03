var app = {
    init: function () {
        $('.input-daterange').datepicker({
            startDate: "today",
            endDate: "+2m",
            format: "D dd M",
            todayHighlight: true,
            autoclose: true,
            orientation: "top auto"
        });

        // $(".place input:text").on('input', function () {
        //     if (this.value.length >= 2)
        //         $(".place .autocomplete").show();
        //     else
        //         $(".place .autocomplete").hide();
        // }).blur(function () {
        //     $(".place .autocomplete").hide();
        // });

        // $(".place .autocomplete .list-group-item").on("mousedown", function () {
        //     $(".place input:text").val($(this).text());
        //     $("html, body").animate({ scrollTop: 0 }, 100);
        // });

        $("#refine .toggle").on("click", function () {
            if ($(document.body).hasClass("sidebar-open"))
                app.refine.close();
            else
                app.refine.open();
        });

        Hotels.init()
    },

    refine: {
        open: function () {
            $(document.body).addClass("sidebar-open");
            $("html, body").animate({ scrollTop: 0 }, 200);
            $("#refine .controls").animate({ scrollTop: 0 }, 200);
        },
        close: function () {
            $(document.body).removeClass("sidebar-open");
        }
    },

    tabSelect: function (sender, tab) {
        var section = $(sender).parents("section:first");
        $(".tabs li", section).not($(sender).parent("li")).removeClass("active");
        $(".tabs-content .content", section).slideUp(200);
        var container = $(".tabs-content .tab-" + tab, section).filter(":hidden").slideDown(200);

        $(sender).parent("li").toggleClass("active");

        this._tabAction(tab, container);

        return false;
    },

    _tabAction: function (tab, container) {
        switch (tab) {
            // case "rooms":
            //     this._loadRooms(container);
            //     break;

            case "best-rooms":
                this._loadBestRooms(container);
                break;
            case "map":
                this._loadMap(container);
                break;
        }
    },

    _loadRooms: function (container) {
        $(".loader", container).show();
        $(".list", container).hide();

        setTimeout(function () {
            $(".loader", container).hide();
            $(".list", container).show();
        }, 1500);
    },

    _loadBestRooms: function (container) {
        $(".loader", container).show();
        $(".list", container).hide();

        setTimeout(function () {
            $(".loader", container).hide();
            $(".list", container).show();
        }, 1500);
    },


    _loadMap: function (container) { 
      var loaded = container.data('map-loaded');

      var mapOptions = {
        zoom: 15,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      var map_container = document.getElementById('google-hotel-map-' + container.data('show-map'))

      container.show(function(){
        if(!loaded)
        {
          var lat = container.data('lat');
          var lng = container.data('lng');
          var mapCenter = {center: new google.maps.LatLng(lat, lng)};   
          
          var map = new google.maps.Map(map_container, $.extend( mapCenter, mapOptions ));

          var marker = new google.maps.Marker({
              position: mapCenter.center,
              map: map
          });  
          container.data('map-loaded', true)
        } 
      }); 
    }    
};

$(app.init);

// Fake stuff

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

// $(function () {
//     for (var i = 0; i < 10; i++) {
//         var item = $("#results section:first").clone();
//         $("#results").append(item);
//     }

//     $("#results .loader").hide();
//     $("#results .overlay").hide();
//     $("#results section .best-deal .logo img").hide();
//     $("#results section .best-deal .high-price").text("--");
//     $("#results section .best-deal .price").text("--");
//     $("#results section").hide();
//     setTimeout(function () {
//         $("#results section").show();
//     }, 500);
//     setTimeout(function () {
//         $("#results .loader").fadeIn('fast');
//         $("#results .overlay").fadeIn('fast');
//     }, 1000);

//     setTimeout(function () {
//         var total = $("#results section").length;

//         $("#results section").each(function (i) {
//             var $this = this;
//             var timeout = i * 200;
//             var n = i + 1;
//             var amount = getRandomInt(n * 100, n * 200);
//             var highAdjust = getRandomInt(0, 50);
//             setTimeout(function () {
//                 $(".best-deal .logo img", $this).show();
//                 $(".best-deal .high-price", $this).text("£" + (amount + highAdjust));
//                 $(".best-deal .price", $this).text("£" + amount);
//                 var percent = ((i + 1) / total) * 100;
//                 $("#results .loader .progress-bar").width(percent + "%");

//                 if ((i + 1) == total) {
//                     setTimeout(function () {
//                         $("#results .loader").fadeOut('fast');
//                         $("#results .overlay").fadeOut('fast');
//                     }, 500);
//                 }

//             }, timeout);
//         });
//     }, 1500);
// });