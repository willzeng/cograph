define ['jquery', 'underscore', 'backbone', 'cs!models/GraphModel', 'cs!models/FilterModel'
  'cs!views/GraphView', 'cs!views/AddNodeView', 'cs!views/DetailsView', 'cs!views/FilterView', 'cs!views/SearchView', 'cs!views/SideBarView'],
  ($, _, Backbone, GraphModel, FilterModel, GraphView, AddNodeView, DetailsView, FilterView, SearchView, SideBarView) ->
    class Router extends Backbone.Router
      initialize: ->
        @graphModel = new GraphModel()
        @graphView = new GraphView model: @graphModel
        @addNodeView = new AddNodeView model: @graphModel
        @detailsView = new DetailsView model: @graphModel
        @filterView = new FilterView {model: @graphModel.getFilter()}
        @searchView = new SearchView model: @graphModel
        @sidebarView = new SideBarView()

        window.gm = @graphModel
        Backbone.history.start()

      routes:
        '': 'home'

      home: ->
        @graphView.render()
        num = Math.round(3+Math.random()*15)
        iter = 0
        n = []
        while (iter<num)
          n.push(iter.toString())
          iter++

        _.each(n, (d) ->
          gm.nodes.add
            name: d
            description: d + " is a wonderful number"
            tags: [d,d+"-ness",d+"-tags"]
        )
        x = Math.round(1+(n.length)*(n.length-1)/2*Math.random()/5)
        i = 0
        while(i<x)
          t = Math.round((n.length-1)*Math.random())
          s = Math.round((n.length-1)*Math.random())
          gm.connections.add
            name: 'related to'+t+s
            source: gm.nodes.findWhere({name:n[s]})
            target: gm.nodes.findWhere({name:n[t]})
          i++
