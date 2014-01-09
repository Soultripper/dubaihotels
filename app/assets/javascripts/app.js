var app = {
    init: function () {
        // $('.input-daterange').datepicker({
        //     startDate: "today",
        //     endDate: "+2m",
        //     format: "D dd M",
        //     todayHighlight: true,
        //     autoclose: true,
        //     orientation: "top auto"
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

    _loadGallery: function (container) {
        if ($("li.active", container).length == 0)
            $("li:first a", container).trigger("click");
    },

    loadImage: function (sender, url) {
        var container = $(sender).parents(".tab-gallery");
        var photoContainer = $(container).find(".photo");
        $("img", photoContainer).css("visibility", "hidden");
        $("ul.thumbs li", container).removeClass("active");
        $(sender).parent().addClass("active");
        var image = new Image();
        console.log(sender)
        image.src = url;
        $(image).load(function () {
            $("img", container).remove();
            $(photoContainer).append(image);
        });
        return false;
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

