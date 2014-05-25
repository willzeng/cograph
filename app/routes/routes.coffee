define ['jquery', 'underscore', 'backbone', 'cs!models/NodeModel', 'cs!models/GraphModel', 'cs!controllers/DataHub','cs!models/FilterModel'
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/FilterView', 'cs!views/SearchView', 'cs!views/SideBarView', 'cs!views/MenuView'],
  ($, _, Backbone, NodeModel, GraphModel, DataHub, FilterModel, GraphView, AddNodeView, DetailsView, FilterView, SearchView, SideBarView, MenuView) ->
    class Router extends Backbone.Router
      initialize: ->
        default_tags = {'node_tags':['theorem','proof','conjecture','citation']}
        @graphModel = new GraphModel initial_tags:default_tags

        @dataHub = new DataHub model: @graphModel

        @graphView = new GraphView model: @graphModel
        @addNodeView = new AddNodeView model: @graphModel
        @detailsView = new DetailsView model: @graphModel
        @filterView = new FilterView {model: @graphModel.getFilter()}
        @searchView = new SearchView model: @graphModel
        @sidebarView = new SideBarView()
        @menuView = new MenuView()

        window.gm = @graphModel
        Backbone.history.start()

      routes:
        '': 'home'

      home: =>
        @graphView.render()

        #Prepopulate the GraphModel with all the nodes in the database
        $.get '/server/get_all_nodes', (nodes) ->
          gm.putNode new NodeModel node for node in nodes

        #@randomPopulate()

      randomPopulate: ->
        num = Math.round(3+Math.random()*15)
        iter = 0
        n = []
        while (iter<num)
          n.push(iter.toString())
          iter++

        _.each(n, (d) ->
          gm.putNode new NodeModel
            name: Math.random().toString(36).substring(7)
            description: d + " is a wonderful number"
            tags: ['conjecture']
        )
        x = Math.round(1+(n.length)*(n.length-1)/2*Math.random()/5)
        i = 0
        while(i<x)
          t = Math.round((n.length-1)*Math.random())
          s = Math.round((n.length-1)*Math.random())
          if t == s
            continue
          gm.connections.add
            name: 'related to'+t+s
            source: gm.nodes.models[t]
            target: gm.nodes.models[s]
          i++
