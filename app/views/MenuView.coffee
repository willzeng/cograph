define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'bootstrap',
 'bb-modal', 'text!templates/new_doc_modal.html', 'text!templates/open_doc_modal.html',
 'text!templates/analytics_modal.html', 'cs!models/DocumentModel', 'socket-io'],
  ($, _, Backbone, Bloodhound, typeahead, bootstrap, bbModal, newDocTemplate, openDocTemplate, analyticsTemplate, DocumentModel, io) ->
    class DocumentCollection extends Backbone.Collection
      model: DocumentModel
      url: 'documents'
      socket: io.connect('')

    class MenuView extends Backbone.View
      el: $ '#gdocs-nav'

      events:
        'click #new-doc-button': 'newDocumentModal'
        'click #open-doc-button': 'openDocumentModal'
        'click #analytics-button': 'openAnalyticsModal'

      initialize: ->
        @model.on "document:change", @render, this
        @model.getDocument().on 'change', @render, this

        $('#menu-title').tooltip({animation:true})
        $('#menu-title').click( ()->
           $(this).select()
        )
        $('#menu-title').bind 'blur', () =>
          @model.getDocument().set 'name', $('#menu-title').val()
          @model.getDocument().save()

        @render()

      render: ->
        $('#menu-title').val @model.getDocument().get('name')

      newDocumentModal: ->
        @newDocModal = new Backbone.BootstrapModal(
          content: _.template(newDocTemplate, {})
          title: "New Document"
          animate: true
          showFooter: false
        ).open()

        @newDocModal.on "shown", () ->
          $(newDocName).focus()
          $("#new-doc-form").submit (e) ->
            false

        $('button', @newDocModal.$el).click () =>
          @newDocument()
          @newDocModal.close()

      newDocument: () ->
        docName = $('#newDocName', @newDocModal.el).val()
        newDocument = new DocumentModel(name: docName)
        $.when(newDocument.save()).then =>
          window.open '/'+newDocument.get('_id')

      openDocumentModal: ->
        documents = new DocumentCollection
        $.when(documents.fetch()).then =>
          modal = new Backbone.BootstrapModal(
            content: _.template(openDocTemplate, {documents: documents})
            title: "Open Document"
            animate: true
            showFooter: false
          ).open()
        false # prevent navigation from appending '#'

      openAnalyticsModal: ->
        @model.getDocument().getAnalytics (analyticsData) ->
          modal = new Backbone.BootstrapModal(
            content: _.template(analyticsTemplate, analyticsData)
            title: "Analytics"
            animate: true
            showFooter: false
          ).open()
