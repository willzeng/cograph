(function(){
  requirejs.config({
    baseUrl: "../",
    cb: 'cb=' + Math.random(),
    paths: {
      'jquery': 'assets/libs/jquery/dist/jquery.min',
      'underscore': 'assets/libs/underscore/underscore',
      'backbone': 'assets/libs/backbone/backbone',
      'text': 'assets/libs/requirejs-text/text',
      'd3': 'assets/libs/d3/d3.min',
      'backbone-forms': 'assets/libs/backbone-forms/distribution.amd/backbone-forms.min',
      'backbone-forms-bootstrap': 'assets/js/backbone-forms/bootstrap3',
      'list': 'assets/libs/backbone-forms/distribution.amd/editors/list.min',
      'typeahead': 'assets/libs/typeahead.js/dist/typeahead.jquery.min',
      'bloodhound': 'assets/libs/typeahead.js/dist/bloodhound.min',
      'bootstrap': 'assets/libs/bootstrap/dist/js/bootstrap.min',
      'bb-modal': 'assets/libs/new-bb-modal/src/backbone.bootstrap-modal',
      'bootstrap-color':'assets/libs/bootstrap-colorpalette/js/bootstrap-colorpalette',
      'share-button': 'assets/libs/share-button/build/share.min',
      'socket-io': '../node_modules/express.io/node_modules/socket.io/node_modules/socket.io-client/dist/socket.io',
      'b-iosync': 'assets/libs/backbone.iobind/dist/backbone.iosync',
      'b-iobind': 'assets/libs/backbone.iobind/dist/backbone.iobind',
      'caret': 'assets/libs/caret.js/dist/jquery.caret.min',
      'atwho': 'assets/libs/targeted-atwho/dist/js/jquery.atwho.min',
      'twittertext': 'assets/libs/twitter-text/pkg/twitter-text-1.9.4.min',
      'linkify': 'assets/libs/jQuery-linkify/dist/jquery.linkify.min',
      'jasmine': 'assets/libs/jasmine/lib/jasmine-core/jasmine',
      'jasmine-html': 'assets/libs/jasmine/lib/jasmine-core/jasmine-html',
      'boot': 'assets/libs/jasmine/lib/jasmine-core/boot'
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
        deps: ['jquery']
      },
      'atwho': {
        deps: ['jquery', 'caret']
      },
      'twittertext': {
        deps: ['jquery']
      },
      'linkify': {
        deps: ['jquery']
      },
      'jasmine': {
        exports: 'window.jasmineRequire'
      },
      'jasmine-html': {
        deps: ['jasmine'],
        exports: 'window.jasmineRequire'
      },
      'boot': {
        deps: ['jasmine', 'jasmine-html'],
        exports: 'window.jasmineRequire'
      }
    },
    packages: [{
        name: 'cs',
        location: 'assets/libs/require-cs',
        main: 'cs'
      }, {
        name: 'coffee-script',
        location: 'assets/libs/coffee-script',
        main: 'index'
    }]
  });

  specs = [
    'cs!tests/NodeModelSpec',
    'cs!tests/GraphViewSpec'
  ];

  require(['boot'], function(boot) {
    require(specs, function() {
      window.onload();
    });
  });

})();
