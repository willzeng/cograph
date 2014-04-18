### This is the main file that constructs the client-side application ###
# It builds an object called Celestrium that has plugins to provide functionality.

# tell requirejs where everything is
requirejs.config

  #This is where all the plugins and Rhizi itself are located
  baseUrl: "."

  # paths tells requirejs to replace the keys with their values
  # in subsequent calls to require
  paths:

    #This is another path where you could put your own local plugins
    local: "."

###

You need only require the Celestrium plugin.
NOTE: it's module loads the globally defined standard js libraries
      like jQuery, underscore, etc...
###

require ["js/Rhizi"], (Rhizi) ->

  ###

  This dictionary defines which plugins are to be included
  and what their arguments are.

  The key is the requirejs path to the plugin.
  The value is passed to its constructor.

  ###
  
  plugins =

    # stores the actual nodes and connections of the graph
    "js/GraphModel": {}

    "js/GraphView": {}

  # initialize the plugins and execute a callback once done
  Rhizi.init plugins, (instances) ->

    console.log "Rhizi initialized"

    initialNodes = ["oen","tow","treeh"]
    instances['js/GraphModel'].putNode node for node in initialNodes

