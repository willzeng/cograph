define ['jquery', 'underscore', 'backbone', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'cs!models/WorkspaceModel', 'cs!models/FilterModel'
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/FilterView', 'cs!views/SearchView', 'cs!views/SideBarView',
  'cs!views/MenuView', 'cs!views/ShareView'],
  ($, _, Backbone, NodeModel, ConnectionModel, WorkspaceModel, FilterModel, GraphView, AddNodeView, DetailsView, FilterView, SearchView, SideBarView, MenuView, ShareView) ->
    class Router extends Backbone.Router
      initialize: ->
        @workspaceModel = new WorkspaceModel()

        @graphView = new GraphView model: @workspaceModel
        @addNodeView = new AddNodeView model: @workspaceModel
        @detailsView = new DetailsView model: @workspaceModel
        @filterView = new FilterView {model: @workspaceModel.getFilter(), attributes: {workspaceModel: @workspaceModel}}
        @searchView = new SearchView model: @workspaceModel
        @sidebarView = new SideBarView model: @workspaceModel
        @menuView = new MenuView model: @workspaceModel
        @shareView = new ShareView model: @workspaceModel
        @shareView.on "save:workspace", (workspaceId) => @navigate ""+workspaceId

        window.gm = @workspaceModel
        Backbone.history.start()

      routes:
        '': 'home'
        '(:id)': 'workspace'

      home: () =>
        @setDoc()

        if window.prefetch.nodes then @workspaceModel.nodes.set window.prefetch.nodes, {silent:true}
        if window.prefetch.connections then @workspaceModel.connections.set window.prefetch.connections, {silent:true}
        @workspaceModel.nodes.trigger "add"

        $('.loading-container').remove()

      # This navigates to a workspace specified by the id
      workspace: (id) ->
        id = parseInt id
        @setDoc()

        @workspaceModel._id = id
        @workspaceModel.getWorkspace (w) =>
          if window.prefetch.nodes
            workspaceNodes = _.filter window.prefetch.nodes, (node) ->
              _.contains w.nodes, node._id
            @workspaceModel.nodes.set workspaceNodes, {silent:true}
          if window.prefetch.connections
            workspaceConns = _.filter window.prefetch.connections, (conn) ->
              _.contains w.connections, conn._id
            @workspaceModel.connections.set workspaceConns, {silent:true}

          @workspaceModel.nodes.trigger "add"
          @workspaceModel.filterModel.set 'node_tags', w.nodeTags

          $('.loading-container').remove()

      setDoc: ->
        @workspaceModel.getDocument().set window.prefetch.theDocument
        @workspaceModel.nodes._docId = window.prefetch.theDocument._id
        @workspaceModel.connections._docId = window.prefetch.theDocument._id

        @workspaceModel.getTagNames (tags) =>
          @workspaceModel.filterModel.addInitialTags tags
          @workspaceModel.filterModel.addNodeTags tags

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
