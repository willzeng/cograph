requirejs.config({
  baseUrl: "",
  paths: {
    'jquery': '/assets/libs/jquery/dist/jquery.min',
    'underscore': '/assets/libs/underscore/underscore',
    'backbone': '/assets/libs/backbone/backbone',
    'text': '/assets/libs/requirejs-text/text',
    'typeahead': '/assets/libs/typeahead.js/dist/typeahead.jquery.min',
    'bloodhound': '/assets/libs/typeahead.js/dist/bloodhound.min',
    'socket-io': '/socket.io/socket.io',
    'b-iosync': '/assets/libs/backbone.iobind/dist/backbone.iosync',
    'b-iobind': '/assets/libs/backbone.iobind/dist/backbone.iobind'
  },
  shim: {
    'backbone': {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    },
    'typeahead': {
      deps: ['jquery']
    },
    'bloodhound': {
      deps: ['jquery']
    },
    'b-iosync': {
      deps: ['underscore','backbone']
    },
    'b-iobind': {
      deps: ['underscore','backbone']
    }
  },
  packages: [{
      name: 'cs',
      location: '/assets/libs/require-cs',
      main: 'cs'
    }, {
      name: 'coffee-script',
      location: '/assets/libs/coffee-script',
      main: 'index'
  }]
});

require(['cs!mobile/views/MobileView'], function(MobileView){
  mobileView = new MobileView()
});
