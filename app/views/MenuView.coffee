define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'bootstrap',
 'bb-modal', 'text!templates/new_doc_modal.html', 'text!templates/open_doc_modal.html',
  'cs!models/DocumentModel'],
  ($, _, Backbone, Bloodhound, typeahead, bootsrap, bbModal, newDocTemplate, openDocTemplate, DocumentModel) ->
    class DocumentCollection extends Backbone.Collection
      model: DocumentModel
      url: 'document'

    class MenuView extends Backbone.View
      el: $ '#menu-bar'

      events:
        'click #new-doc-button': 'newDocumentModal'
        'click #open-doc-button': 'openDocumentModal'

      newDocumentModal: ->
        @newDocModal = new Backbone.BootstrapModal(
          content: _.template(newDocTemplate, {})
          title: "New Document"
          animate: true
          showFooter: false
        ).open()

        $('button', @newDocModal.$el).click => @newDocument()

      newDocument: ->
        true

      openDocumentModal: ->
        documents = new DocumentCollection()
        documents.fetch()
        modal = new Backbone.BootstrapModal(
          content: _.template(openDocTemplate, {documents: documents}),
          title: "Open Document"
          animate: true
          showFooter: false
        ).open()
