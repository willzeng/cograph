define ['cs!models/NodeModel'], (NodeModel) ->
  describe "NodeModel", ->
    defaults = new NodeModel()
    it "name should default to blank", () ->
      expect(defaults.get('name')).toBe("")
