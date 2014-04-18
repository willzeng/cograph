###

only module that needs to be included by a user's requirejs main script.
also loads all the libraries with global definitions.
exposes an object with an `init` function which takes two arguments.

  1. dictionary of plugins
    - keys are singleton plugin requirejs paths
    - values are the arguments to that plugin's factory function
  2. callback
    - guaranteed to be called *after* all instances are created
      as well as globally defined libraries

###

requirejs.config
  shim:
    "/libs/backbone": ["./underscore"]

globalLibs = [
  '/libs/jquery/dist/jquery.js',
  '/libs/underscore/underscore.js',
  '/libs/backbone/backbone.js'
]

define globalLibs, () ->
  init: (pluginsDict, callback) ->
    pluginPaths = _.keys(pluginsDict)
    instances = {}
    require pluginPaths, (plugins...) ->
      console.log plugins
      _.each plugins, (plugin, i) ->
        options = pluginsDict[pluginPaths[i]]
        instance = new plugin(options)
        instance.init instances
        instances[pluginPaths[i]] = instance
        window.instances = instances
      callback(instances) if callback?
