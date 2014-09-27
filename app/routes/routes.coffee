define ['jquery', 'underscore', 'backbone', 'cs!models/NodeModel', 'cs!models/ConnectionModel', 'cs!models/WorkspaceModel', 'cs!models/FilterModel'
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/FilterView', 'cs!views/SearchView', 'cs!views/SideBarView',
  'cs!views/MenuView', 'cs!views/ShareView', 'cs!views/FeedbackView'],
  ($, _, Backbone, NodeModel, ConnectionModel, WorkspaceModel, FilterModel, GraphView, AddNodeView, DetailsView, FilterView, SearchView, SideBarView, MenuView, ShareView, FeedbackView) ->
    class Router extends Backbone.Router
      initialize: ->
        @workspaceModel = new WorkspaceModel()

        @feedbackView = new FeedbackView
        @graphView = new GraphView model: @workspaceModel
        @addNodeView = new AddNodeView model: @workspaceModel
        @detailsView = new DetailsView {model: @workspaceModel, attributes: {graphView: @graphView}}
        @filterView = new FilterView {model: @workspaceModel.getFilter(), attributes: {workspaceModel: @workspaceModel}}
        @searchView = new SearchView model: @workspaceModel
        @sidebarView = new SideBarView model: @workspaceModel
        @menuView = new MenuView model: @workspaceModel
        @shareView = new ShareView model: @workspaceModel

        @shareView.on "save:workspace", (workspaceId) => @navigate "view/"+workspaceId
        @graphView.on "tag:click", (tag) =>
          @workspaceModel.filterModel.set "node_tags", [tag]
          @workspaceModel.filter()
          @searchView.search {value:tag, type:"tag"}
          @navigate "search/"+tag

        window.gm = @workspaceModel
        # regex to extract away a routing pathname
        # this needs to operate for both /username/document/:docId
        # and /:docId
        pathRegex = /^((?:\/\w+\/document)?\/\d+\/?)(?:.+)?$/
        path = pathRegex.exec window.location.pathname
        Backbone.history.start {pushState: true, root: path[1]}

      routes:
        '': 'home'
        'view/:id': 'workspace'
        'search/:tag': 'loadByTag'

      home: () =>
        @setDoc()
        @loadGraph()

      # This navigates to a workspace specified by the id
      workspace: (id) ->
        id = parseInt id
        @setDoc()

        @workspaceModel.set '_id', id
        @workspaceModel.getWorkspace (w) =>
          if w.err
            @navigate "/"
            @loadGraph()
          else
            nodeFilter = (node) -> _.contains w.nodes, node._id
            connFilter = (conn) -> _.contains w.connections, conn._id
            @loadGraph nodeFilter, connFilter
            @workspaceModel.filterModel.set 'node_tags', w.nodeTags

      # Load a graph based on preset filters
      # Defaults to loading the whole prefetch
      loadGraph: (nodeFilter, connFilter) ->
        if !(nodeFilter?) then nodeFilter = (x) -> true
        if !(connFilter?) then connFilter = (x) -> true

        if window.prefetch.nodes
          workspaceNodes = _.filter window.prefetch.nodes, nodeFilter
          @workspaceModel.nodes.set workspaceNodes, {silent:true}
        if window.prefetch.connections
          workspaceConns = _.filter window.prefetch.connections, connFilter
          @workspaceModel.connections.set workspaceConns, {silent:true}

        @workspaceModel.trigger "init"
        $('.loading-container').remove()

      setDoc: ->
        @workspaceModel.getDocument().set window.prefetch.theDocument
        # We need to join the right socket session
        @workspaceModel.socket.emit 'open:document', window.prefetch.theDocument
        @workspaceModel.nodes._docId = window.prefetch.theDocument._id
        @workspaceModel.connections._docId = window.prefetch.theDocument._id

        @workspaceModel.getTagNames (tags) =>
          @workspaceModel.filterModel.addInitialTags tags
          @workspaceModel.filterModel.addNodeTags tags

      loadByTag: (tag) ->
        @setDoc()
        @searchView.search {value:tag, type:"tag"}
        $('.loading-container').remove()

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
