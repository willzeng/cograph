requirejs.config({
  baseUrl: "",
  paths: {
    'jquery': '/assets/libs/jquery/dist/jquery.min',
    'underscore': '/assets/libs/underscore/underscore',
    'backbone': '/assets/libs/backbone/backbone',
    'text': '/assets/libs/requirejs-text/text',
    'd3': '/assets/libs/d3/d3.min'
  },
  shim: {
    'backbone': {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
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

require(['cs!Rhizi'], function(Rhizi){
  Rhizi.initialize()
});
