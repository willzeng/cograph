requirejs.config({
  baseUrl: "/",
  paths: {
    'jquery': '/assets/libs/jquery/dist/jquery.min',
    'underscore': '/assets/libs/underscore/underscore',
    'backbone': '/assets/libs/backbone/backbone',
    'text': '/assets/libs/requirejs-text/text',
    'd3': '/assets/libs/d3/d3',
    'backbone-forms': '/assets/libs/backbone-forms/distribution.amd/backbone-forms.min',
    'backbone-forms-bootstrap': '/assets/js/backbone-forms/bootstrap3',
    'list': '/assets/libs/backbone-forms/distribution.amd/editors/list.min',
    'typeahead': '/assets/libs/typeahead.js/dist/typeahead.jquery.min',
    'bloodhound': '/assets/libs/typeahead.js/dist/bloodhound.min',
    'bootstrap': '/assets/libs/bootstrap/dist/js/bootstrap.min',
    'bb-modal': '/assets/libs/new-bb-modal/src/backbone.bootstrap-modal',
    'bootstrap-color':'/assets/libs/bootstrap-colorpalette/js/bootstrap-colorpalette',
    'share-button': '/assets/libs/share-button/build/share.min',
    'socket-io': '/socket.io/socket.io',
    'b-iosync': '/assets/libs/backbone.iobind/dist/backbone.iosync',
    'b-iobind': '/assets/libs/backbone.iobind/dist/backbone.iobind',
    'caret': '/assets/libs/caret.js/dist/jquery.caret.min',
    'atwho': '/assets/libs/targeted-atwho/dist/js/jquery.atwho.min',
    'twittertext': '/assets/libs/twitter-text/pkg/twitter-text-1.9.4.min',
    'linkify': '/assets/libs/jQuery-linkify/dist/jquery.linkify.min',
    'jquery-autosize': '/assets/libs/jquery-autosize/jquery.autosize',
    'feedback-bot': '/assets/libs/feedback-bot/dist/feedback.0.3.1'
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
    },
    'b-iosync': {
      deps: ['underscore','backbone', 'socket-io']
    },
    'b-iobind': {
      deps: ['underscore','backbone', 'socket-io']
    },
    'caret': {
      deps: ['jquery'],
      exports: 'jQuery.fn.caret'
    },
    'atwho': {
      deps: ['jquery', 'caret'],
      exports: 'jQuery.fn.atwho'
    },
    'twittertext': {
      deps: ['jquery']
    },
    'linkify': {
      deps: ['jquery']
    },
    'feedback-bot': {
      deps: ['jquery']
    },
    'jquery-autosize': {
      deps: ['jquery']
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

require(['jquery','caret','atwho', 'cs!GraphDocs', 'bb-modal', 'cs!routes/routes'],
  function($, caret, atwho, GraphDocs, bbModal, router){
  GraphDocs.initialize();
});
