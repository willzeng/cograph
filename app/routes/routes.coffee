define ['jquery', 'underscore', 'backbone', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'cs!models/WorkspaceModel', 'cs!models/FilterModel'
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/FilterView', 'cs!views/SearchView', 'cs!views/SideBarView',
  'cs!views/MenuView'],
  ($, _, Backbone, NodeModel, ConnectionModel, WorkspaceModel, FilterModel, GraphView, AddNodeView, DetailsView, FilterView, SearchView, SideBarView, MenuView) ->
    class Router extends Backbone.Router
      initialize: ->
        default_tags = {'node_tags':['theorem','proof','conjecture','citation']}
        @workspaceModel = new WorkspaceModel initial_tags:default_tags

        @graphView = new GraphView model: @workspaceModel
        @addNodeView = new AddNodeView model: @workspaceModel
        @detailsView = new DetailsView model: @workspaceModel
        @filterView = new FilterView {model: @workspaceModel.getFilter()}
        @searchView = new SearchView model: @workspaceModel
        @sidebarView = new SideBarView()
        @menuView = new MenuView model: @workspaceModel

        window.gm = @workspaceModel
        Backbone.history.start()

      routes:
        '': 'home'

      home: =>
        @graphView.render()

        #Prepopulate the WorkspaceModel with all the nodes in the database
        $.when(gm.nodes.fetch()).then(gm.connections.fetch())

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
