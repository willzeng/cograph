define ['cs!views/GraphView', 'cs!models/WorkspaceModel', 'cs!models/NodeModel'],
(GraphView, WorkspaceModel, NodeModel) ->
  describe "GraphView", ->
    @workspaceModel = new WorkspaceModel()

    defaults = new GraphView model: @workspaceModel
    it "should have a workspaceModel", () ->
      expect(defaults.model).toBeDefined()

    it "should center after workspaceModel triggers 'found:node'", () ->
      blankNode = new NodeModel
      blankNode.x = 10
      blankNode.y = 10
      defaults.model.trigger "found:node", blankNode
      expect(defaults.zoom.translate()).toEqual([$(window).width()/2-blankNode.x,$(window).height()/2-blankNode.y])
