app = angular.module('Hotels', ['ngResource']).config(function($routeProvider, $locationProvider) {

 $routeProvider.when('/:id', {
    templateUrl: 'templates/hotels.html',
    controller: HotelCtrl  
  })

  $locationProvider.html5Mode(true);
});


var actions = { 
  'get':    {method:'GET', isArray:true}
};

app.factory("Hotel", function($resource){  
  return $resource(":id/?page_no=:page_no&start_date=:start_date&end_date=:end_date&sort=:sort", {page_no: 1});
})

function HotelCtrl($scope, $route, $routeParams, $timeout, $location,  Hotel) {
  var data = { hotels: [], calls: 1 };
  alert('test')
  var param = function(name, default_val){
    return  $location.search()[name] || default_val;
  }

  var poller = function() {
    if(!$routeParams.id) return;
    Hotel.get({id: $routeParams.id, page_no: param('page_no', 1) , sort: param('sort'), end_date: param('end_date'), start_date: param('start_date')}, function(response) {
      data.calls++;

      $scope.hotels = response.hotels;
      $scope.total_hotels = response.total_hotels;
      $scope.available_hotels = response.available_hotels;
      if(!response.finished && data.calls < 10)
        $timeout(poller, 2000);
    });      
  };
  poller();



  // Hotel = $resource("/hotels/:id", {id: '@id'})
  // $scope.hotels = hotelFixtures.hotels
  // console.log(Hotel.data.hotels)
  // $scope.hotels = Hotel.data.hotels
  // var data = Hotel.get(function(response){
  //   $scope.hotels = response.hotels
  // });
  
  // $scope.currency = hotelFixtures.currency;
  // $scope.hotels = hotelFixtures.hotels;
}


var hotelFixtures = {
   "query":"dubai",
   "criteria":{
      "start_date":"2013-10-18",
      "end_date":"2013-10-25",
      "min_stars":1,
      "max_stars":5,
      "currency_code":"GBP",
      "currency_symbol":"£"
   },
   "finished":false,
   "hotels":[
      {
         "id":176884,
         "address1":"Al Mina Road",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.24284,
         "location":"Near Zabeel Park",
         "longitude":55.27579,
         "name":"Mercure Gold Hotel Al Mina Road Dubai",
         "postal_code":"66431",
         "star_rating":4.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":177123,
         "address1":"P.O BOX 14042",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.2605,
         "location":"In Dubai (Deira)",
         "longitude":55.3246,
         "name":"Orchid Hotel",
         "postal_code":null,
         "star_rating":3.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176875,
         "address1":"Crescent Road",
         "address2":"The Palm",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.13092,
         "location":"Near Aquaventure",
         "longitude":55.11635,
         "name":"Atlantis The Palm",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_108_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_114_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_114_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_113_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_113_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_112_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_112_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_111_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_111_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_110_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_110_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_108_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_108_t.jpg",
               "caption":"Exterior",
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_129_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_129_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_125_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_125_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_127_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_127_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_126_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/4700/4633/4633_126_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176876,
         "address1":"Jumeirah Beach Road Po Box 74147",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.14087,
         "location":"Near Wild Wadi Water Park",
         "longitude":55.18593,
         "name":"Burj Al Arab",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_85_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_80_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_80_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_79_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_79_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_78_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_78_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_82_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_82_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_81_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_81_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_92_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_92_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_77_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_77_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_76_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_76_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_75_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_75_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_74_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/440000/436300/436228/436228_74_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176877,
         "address1":"The Walk, Jumeirah Beach",
         "address2":"Jumeirah",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.07857,
         "location":"Near Dubai Marina Mall",
         "longitude":55.13389,
         "name":"Hilton Dubai Jumeirah Residences",
         "postal_code":"2431",
         "star_rating":4.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_19_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_37_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_37_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_36_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_36_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_35_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_35_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_34_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_34_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_33_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_33_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_32_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_32_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_31_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_31_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_30_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_30_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_29_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_29_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_28_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/570000/561900/561816/561816_28_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176878,
         "address1":"Al Mankhool Road Bur Dubai",
         "address2":"Post Box 9168",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.25223,
         "location":"Near BurJuman Mall",
         "longitude":55.29451,
         "name":"Golden Sands Hotel Apartments",
         "postal_code":null,
         "star_rating":4.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_107_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_115_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_115_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_114_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_114_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_113_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_113_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_112_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_112_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_111_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_111_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_110_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_110_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_109_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_109_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_108_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_108_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_107_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_107_t.jpg",
               "caption":"Exterior",
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_106_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/50000/47400/47377/47377_106_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176879,
         "address1":"Jumeirah Beach - Dubai Marina",
         "address2":"PO Box 473828",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.07503,
         "location":"Near Dubai Marina Mall",
         "longitude":55.13258,
         "name":"Sofitel Dubai Jumeirah Beach",
         "postal_code":"0",
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176880,
         "address1":"The Walk Jbr",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.07364,
         "location":"Near Dubai Marina Mall",
         "longitude":55.13022,
         "name":"Ocean View Hotel",
         "postal_code":"26500",
         "star_rating":4.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176881,
         "address1":"Sheikh Zayed Road",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.21121,
         "location":"Near Dubai Zoo",
         "longitude":55.27739,
         "name":"Rose Rayhaan by Rotana Dubai",
         "postal_code":"126452",
         "star_rating":4.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_69_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_79_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_79_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_76_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_76_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_73_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_73_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_70_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_70_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_74_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_74_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_81_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_81_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_78_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_78_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_71_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_71_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_82_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_82_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_75_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/30000/28300/28264/28264_75_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176882,
         "address1":"Jumeirah Beach Road",
         "address2":"Po Box 11416",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.14136,
         "location":"Near Wild Wadi Water Park",
         "longitude":55.19181,
         "name":"Jumeirah Beach Hotel",
         "postal_code":"11416",
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176883,
         "address1":"Oud Metha, Dubai Healthcare City",
         "address2":"Near Sheikh Zaye3d Rd & Wafi Mall",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.2281,
         "location":"In Dubai (Bur Dubai)",
         "longitude":55.3384,
         "name":"Grand Hyatt Dubai",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176885,
         "address1":"Palm Jumeirah",
         "address2":"East Crescent",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.12204,
         "location":"Near Aquaventure",
         "longitude":55.15412,
         "name":"Rixos The Palm Dubai",
         "postal_code":"18652",
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176886,
         "address1":"JBR, The Walk, PO Box 2431",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.07857,
         "location":"Near Dubai Marina Mall",
         "longitude":55.13389,
         "name":"Hilton Dubai Jumeirah Resort",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176887,
         "address1":"Dubai Marina",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.09124,
         "location":"Near Dubai Marina",
         "longitude":55.14926,
         "name":"Tamani Hotel Marina",
         "postal_code":"215855",
         "star_rating":5.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_64_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_65_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_65_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_64_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_64_t.jpg",
               "caption":"Exterior",
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_63_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_63_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_62_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_62_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_61_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_61_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_60_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_60_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_58_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_58_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_57_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_57_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_56_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_56_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_55_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/20000/11900/11821/11821_55_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176888,
         "address1":"Off Sheikh Zayed Road",
         "address2":"Adjacent to Ibn Battuta Mall",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.04144,
         "location":"Near Ibn Battuta Mall",
         "longitude":55.11592,
         "name":"Moevenpick Hotel Ibn Battuta Gate - Dubai",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176889,
         "address1":"Silicon Oasis",
         "address2":"Po Box 35118",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.12295,
         "location":"Near Dubai Silicon Oasis",
         "longitude":55.37435,
         "name":"Premier Inn Dubai Silicon Oasis",
         "postal_code":null,
         "star_rating":3.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176890,
         "address1":"Po Box 24970",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.08421,
         "location":"Near Dubai Marina Mall",
         "longitude":55.14052,
         "name":"Le Royal Meridien Beach Resort And Spa",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176891,
         "address1":"1 Sheikh Zayed Road",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.21145,
         "location":"In Dubai (Trade Centre 1)",
         "longitude":55.27476,
         "name":"Chelsea Tower Suites & Apartments",
         "postal_code":null,
         "star_rating":4.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176892,
         "address1":"Al Fahidi Street",
         "address2":"P.O. BOX 46500",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.26265,
         "location":"Near Textile Souk",
         "longitude":55.29722,
         "name":"Arabian Courtyard Hotel & Spa",
         "postal_code":null,
         "star_rating":4.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176893,
         "address1":"Bani Yas Road",
         "address2":"Deira",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.26542,
         "location":"In Dubai (Deira)",
         "longitude":55.31155,
         "name":"Radisson Blu Hotel, Dubai Deira Creek",
         "postal_code":null,
         "star_rating":4.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_21_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_30_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_30_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_29_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_29_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_28_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_28_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_27_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_27_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_26_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_26_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_25_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_25_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_23_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_23_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_22_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_22_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_21_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_21_t.jpg",
               "caption":"Exterior",
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_35_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/800000/799800/799717/799717_35_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176894,
         "address1":"Al Sofouh Road, Jumeirah Beach",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.09179,
         "location":"Near Dubai Marina Mall",
         "longitude":55.14732,
         "name":"Le Meridien Mina Seyahi Beach Resort & Marina",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176895,
         "address1":"Abu Baker Al Siddque & Sallahuddin Road",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.27074,
         "location":"In Dubai (Deira)",
         "longitude":55.33,
         "name":"Moevenpick Hotel Deira",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176896,
         "address1":"Green Communiy",
         "address2":"PO BOX 35118",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.00799,
         "location":"In Dubai (Green Community)",
         "longitude":55.15697,
         "name":"Premier Inn Dubai Investment Park",
         "postal_code":"00000",
         "star_rating":3.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_130_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_152_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_152_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_149_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_149_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_146_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_146_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_143_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_143_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_136_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_136_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_133_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_133_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_130_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_130_t.jpg",
               "caption":"Exterior",
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_148_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_148_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_145_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_145_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_142_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/430000/426300/426210/426210_142_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176897,
         "address1":"Emirates Hills",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.06754,
         "location":"Near Montgomerie Golf Club",
         "longitude":55.16399,
         "name":"The Address Montgomerie Dubai",
         "postal_code":"36700",
         "star_rating":5.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_20_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_23_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_23_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_22_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_22_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_21_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_21_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_20_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_20_t.jpg",
               "caption":"Exterior",
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_18_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_18_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_16_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/890000/889000/888964/888964_16_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176898,
         "address1":"Mankhool Road",
         "address2":"Bur Dubai",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.2534,
         "location":"Near BurJuman Mall",
         "longitude":55.2938,
         "name":"Majestic Hotel Tower",
         "postal_code":"122235",
         "star_rating":4.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_24_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_40_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_40_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_39_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_39_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_38_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_38_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_37_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_37_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_36_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_36_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_35_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_35_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_34_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_34_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_33_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_33_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_31_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_31_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_29_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/460000/455600/455557/455557_29_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176899,
         "address1":"Airport Road",
         "address2":"P O Box 10001",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.2494,
         "location":"Near Dubai Tennis Stadium",
         "longitude":55.34791,
         "name":"Le Meridien Dubai",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176900,
         "address1":"Dubai Airports",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.24847,
         "location":"In Dubai (Deira)",
         "longitude":55.36176,
         "name":"Dubai International Airport Terminal Hotel",
         "postal_code":"35566",
         "star_rating":4.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176901,
         "address1":"Sheikh Khalifah Bin Zayed Street",
         "address2":"Opp. Burjuman Centre",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.24962,
         "location":"Near BurJuman Mall",
         "longitude":55.30152,
         "name":"Park Regis Kris Kin Hotel Dubai",
         "postal_code":"8264",
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      },
      {
         "id":176902,
         "address1":"Palm Jumeirah",
         "address2":null,
         "city":"Dubai",
         "country":"AE",
         "latitude":25.11045,
         "location":"Near Aquaventure",
         "longitude":55.14126,
         "name":"Fairmont The Palm",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_26_b.jpg",
         "images":[
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_33_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_33_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_32_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_32_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_31_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_31_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_51_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_51_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_50_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_50_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_49_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_49_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_48_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_48_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_47_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_47_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_46_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_46_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            },
            {
               "url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_45_b.jpg",
               "thumbnail_url":"http://media.expedia.com/hotels/1000000/10000/7400/7378/7378_45_t.jpg",
               "caption":null,
               "width":350,
               "height":350
            }
         ],
         "providers":[

         ]
      },
      {
         "id":176903,
         "address1":"P.O. Box 116656",
         "address2":"Kuwait Street, 23",
         "city":"Dubai",
         "country":"AE",
         "latitude":25.2553,
         "location":"In Dubai (Bur Dubai)",
         "longitude":55.2859,
         "name":"Melia Dubai",
         "postal_code":null,
         "star_rating":5.0,
         "state_province":null,
         "main_image":"",
         "images":[

         ],
         "providers":[

         ]
      }
   ]
}