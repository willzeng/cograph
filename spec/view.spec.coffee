define ['cs!src/view'], (View) ->

  # Make sure Backbone.JS is available in the global namespace
  initBackbone()

  describe 'View', ->

    props = echo: 'Hello, world!'
    view = null

    beforeEach ->
      view = new View(props)

    it 'echoes echo param in a paragraph', ->
      view.render()
      expect(view.$el.html()).toEqual('<p>' + props.echo + '</p>')

    it 'handles click event', ->
      spyOn view, 'onClick'
      view.delegateEvents() # re-bind click event to spy
      view.$el.click()
      expect(view.onClick).toHaveBeenCalled()