define ['cs!models/NodeModel'], (NodeModel) ->
  describe "NodeModel", ->
    defaults = new NodeModel()
    it "name should default to blank", () ->
      expect(defaults.get('name')).toBe("")

    it "_id should default to -1", () ->
      expect(defaults.get('_id')).toBe(-1)