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

  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };

  Pusher.host = 'ws-eu.pusher.com';
  Pusher.sockjs_host = 'sockjs-eu.pusher.com';

  var key = 'tes',
      channel = null,
      subscribedChannel = null,
      client = null;

  var init = function(key){
    this.key = key
    client = new Pusher(key, { cluster: 'eu' });
    return this;
  };

  var bindChannel = function(){
    subscribedChannel.bind('results_update', function(push_envelope) {
      var domElement = $('#wrapper')
      angular.element(domElement).scope().pollSearch() 
    })     
  }

  var subscribe = function(newChannel){
    channel = newChannel
    subscribedChannel = client.subscribe(channel)
    bindChannel()
    return subscribedChannel
  };

  var unsubscribe = function(){
    if(channel)
      client.unsubscribe(channel)
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
    unsubscribe: unsubscribe,
    changeChannel: changeChannel
  }
}();