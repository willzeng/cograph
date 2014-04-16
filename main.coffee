### This is the main file that constructs the client-side application ###
# It builds an object called Celestrium that has plugins to provide functionality.

# tell requirejs where everything is
requirejs.config

  #This is where all the plugins and Celestrium itself are located
  baseUrl: "/core/"

  # paths tells requirejs to replace the keys with their values
  # in subsequent calls to require
  paths:

    #This is another path where you could put your own local plugins
    local: "."
