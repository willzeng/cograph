define ['cs!models/NodeModel'], (NodeModel) ->
  'use strict'

  describe "NodeModel", ->
    defaults = new NodeModel()
    it "name should default to blank", () ->
      expect(defaults.get('name')).toBe("")
