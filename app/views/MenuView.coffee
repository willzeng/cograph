define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'bootstrap',
 'bb-modal', 'text!templates/new_doc_modal.html', 'text!templates/open_doc_modal.html',
  'cs!models/DocumentModel', 'cs!models/WorkspaceModel'],
  ($, _, Backbone, Bloodhound, typeahead, bootstrap, bbModal, newDocTemplate, openDocTemplate, DocumentModel) ->
    class DocumentCollection extends Backbone.Collection
      model: DocumentModel
      url: 'documents'
      socket: new DocumentModel().get('socket')

    class MenuView extends Backbone.View
      el: $ '#menu-bar'

      events:
        'click #new-doc-button': 'newDocumentModal'
        'click #open-doc-button': 'openDocumentModal'

      initialize: ->
        @model.on "document:change", @render, this

        $('#menu-title').bind 'input', () =>
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
        document = new DocumentModel(name: docName)
        $.when(document.save()).then =>
          @model.setDocument document

      openDocumentModal: ->
        documents = new DocumentCollection
        $.when(documents.fetch()).then =>
          modal = new Backbone.BootstrapModal(
            content: _.template(openDocTemplate, {documents: documents})
            title: "Open Document"
            animate: true
            showFooter: false
          ).open()
