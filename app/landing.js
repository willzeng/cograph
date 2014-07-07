requirejs.config({
  baseUrl: "",
  paths: {
    'jquery': '/assets/libs/jquery/dist/jquery.min',
    'underscore': '/assets/libs/underscore/underscore',
    'backbone': '/assets/libs/backbone/backbone',
    'text': '/assets/libs/requirejs-text/text',
    'backbone-forms': '/assets/libs/backbone-forms/distribution.amd/backbone-forms.min',
    'backbone-forms-bootstrap': '/assets/js/backbone-forms/bootstrap3',
    'list': '/assets/libs/backbone-forms/distribution.amd/editors/list.min',
    'typeahead': '/assets/libs/typeahead.js/dist/typeahead.jquery.min',
    'bloodhound': '/assets/libs/typeahead.js/dist/bloodhound.min',
    'bootstrap': '/assets/libs/bootstrap/dist/js/bootstrap.min',
    'bb-modal': '/assets/libs/backbone.bootstrap-modal/src/backbone.bootstrap-modal',
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
    'bootstrap': {
      deps: ['jquery']
    },
    'bb-modal': {
      deps: ['underscore', 'jquery', 'backbone']
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

require(['cs!views/LandingView'], function(LandingView){
  landingView = new LandingView()
});
