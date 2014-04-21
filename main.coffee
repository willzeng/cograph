requirejs.config
  baseUrl: "."
  paths:
    'jquery': '/libs/jquery/dist/jquery.min'
    'underscore': '/libs/underscore/underscore'
    'backbone': '/libs/backbone/backbone'
  shim:
    'backbone':
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
  plugins =
    "js/GraphModel": {}
    "js/GraphView": {}
    "js/Rhizi": {}

require ['js/Rhizi'], (Rhizi) ->
  Rhizi.initialize()
