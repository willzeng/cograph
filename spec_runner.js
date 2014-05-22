var requirejs = require('requirejs');

// list all the tests to be run
var specs = [
    'cs!specs/test.spec'
  , 'cs!specs/view.spec'
]

// set up require.js to play nicely with the test environment
requirejs.config({
    baseUrl: './',
    nodeRequire: require,
    paths: {
        // paths to coffeescript+cs wrapper plugin
        cs            : 'node_modules/coffee-script'
      , CoffeeScript  : '/app/assets/libs/coffee-script/index'
    }
});

// make define available globally like it is in the browser
global.define = require('requirejs');
jasmine = require('jasmine-node');

// map jasmine methods to global namespace
for (key in jasmine) {
    if (jasmine[key] instanceof Function) {
    global[key] = jasmine[key];
  }
}

// Test helper: set up a faux-DOM for running browser tests
global.initDOM = function () { 

  // Create a DOM
  jsdom = require('jsdom');

  // create a jQuery instance
  jQuery = require('jquery').create();
  global.jQuery = global.$ = jQuery;

  // Create window
  window = jsdom.jsdom().createWindow('<html><body></body></html>')

  // Set up global references for DOMDocument+jQuery
  global.document = window.document;

  // add addEventListener for coffeescript compatibility:
  global.addEventListener = window.addEventListener
}

// Test helper: set up Backbone.js with a browser-like environment
global.initBackbone = function () {

  // Get a headless DOM ready for action
  global.initDOM();

  // add Backbone to global namespace and tell it to use jQuery
  global.Backbone = require('backbone');
  if (global.Backbone.setDomLibrary === undefined) 
    global.Backbone.$ = jQuery;
  else
    global.Backbone.setDomLibrary(jQuery);
}

// require specs and run them with Jasmine as soon as they're loaded
requirejs(specs, function () {

  // tell Jasmine to use the boring console reporter:
    jasmine.getEnv().addReporter(new jasmine.ConsoleReporter());

  // execute all specs
    jasmine.getEnv().execute();
});