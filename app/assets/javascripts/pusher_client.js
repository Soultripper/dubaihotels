var Hot5 = {}

var PusherClient = function(key, channel){

  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };

  Pusher.host = 'ws-eu.pusher.com';
  Pusher.sockjs_host = 'sockjs-eu.pusher.com';
  
  var pusher = new Pusher(key, { cluster: 'eu' });
  var channel = pusher.subscribe(channel);
  channel.bind('results_update', function(push_envelope) {
    var domElement = $('#searchController')
    angular.element(domElement).scope().pollSearch() 
  })
}


Hot5.Connections || (Hot5.Connections = {})

Hot5.Connections.Pusher = {
  key: null,
  channel: null,
  client: null,
  init: function(key, channel){
    Hot5.Connections.Pusher.key = key
    Hot5.Connections.Pusher.channel = channel    
  },  
  subscribe: function(){
    client = new PusherClient(Hot5.Connections.Pusher.key, Hot5.Connections.Pusher.channel)
  }
}