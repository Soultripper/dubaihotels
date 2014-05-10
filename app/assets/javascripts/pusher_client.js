var Hot5 = {}

Hot5.Connections || (Hot5.Connections = {})

// var PusherClient = function(key, channel){



  
//   var pusher =
//   // var channel = pusher.subscribe(channel);


//   return {
//     instance: pusher
//   }
// }



// Hot5.Connections.Pusher = {
//   key: null,
//   channel: null,
//   client: null,
//   init: function(key, channel){
//     Hot5.Connections.Pusher.key = key
//     Hot5.Connections.Pusher.channel = channel    
//   },  
//   subscribe: function(){
//     client = new PusherClient(Hot5.Connections.Pusher.key, Hot5.Connections.Pusher.channel)
//   },
//   unsubscribe: function(){
//     Hot5.Connections.Pusher.client.instance.unsubscribe()
//   } 
//   changeChannel: function(){

//   }
// }

Hot5.Connections.Pusher = function()
{

  // Pusher.log = function(message) {
  //   if (window.console && window.console.log) window.console.log(message);
  // };

  Pusher.host = 'ws-eu.pusher.com';
  Pusher.sockjs_host = 'sockjs-eu.pusher.com';

  var key = null,
      channel = null,
      subscribedChannel = null,
      hotelChannels = [],
      client = null;

  var init = function(key){
    this.key = key
    client = new Pusher(key, { cluster: 'eu' });
    return this;
  };

  var subscribe = function(newChannel){
    channel = newChannel
    subscribedChannel = client.subscribe(channel)
    subscribedChannel.bind('results_update', function(push_message) {
      var domElement = $('#hotel-results')
      if(angular.element(domElement).scope().search)
        angular.element(domElement).scope().search() 
    })     
  };

  var isHotelSubscribed = function(hotelChannel){
    if(_.contains(hotelChannels, hotelChannel)) return true;    
  };

  var subscribeHotel = function(hotelChannel, subscription_succeeded, event_callback){

    if(isHotelSubscribed(hotelChannel)) return false;    

    subscribedHotelChannel = client.subscribe(hotelChannel)
    subscribedHotelChannel.bind('pusher:subscription_succeeded', subscription_succeeded)
    hotelChannels.push(hotelChannel)
    subscribedHotelChannel.bind('availability_update', function(push_message) {

      event_callback(push_message)
    })     
  };

  var unsubscribeHotel = function(hotelChannel){
    var existingChannel = client.channel(hotelChannel);
    if(existingChannel)
      client.unsubscribe(hotelChannel);
  };

  var unsubscribe = function(){
    if(channel && subscribedChannel)
    {
      client.unsubscribe(channel)
      subscribedChannel = null;
    }
  };
   
  var changeChannel = function(newChannel){
    if(newChannel && channel!=newChannel){
      unsubscribe();
      subscribe(newChannel)
    }
  };

  return {
    init: init,
    subscribe: subscribe,
    subscribeHotel: subscribeHotel,
    unsubscribeHotel: unsubscribeHotel,
    isHotelSubscribed: isHotelSubscribed,
    unsubscribe: unsubscribe,
    changeChannel: changeChannel
  }
}();