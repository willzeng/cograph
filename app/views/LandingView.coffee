define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'bootstrap',
 'bb-modal', 'text!templates/new_doc_modal.html', 'text!templates/open_doc_modal.html',
  'cs!models/DocumentModel', 'socket-io'],
  ($, _, Backbone, Bloodhound, typeahead, bootstrap, bbModal, newDocTemplate, openDocTemplate, DocumentModel, io) ->
    class DocumentCollection extends Backbone.Collection
      model: DocumentModel
      url: 'documents'
      socket: io.connect('')

    class LandingView extends Backbone.View
      el: $ '#button-container'

      events:
        'click #create': 'newGraphDoc'
        'click #open': 'openDocumentModal'

      newGraphDoc: ->
        window.open '/'

      openDocumentModal: ->
        documents = new DocumentCollection window.prefetch
        documents.fetch()

        modal = new Backbone.BootstrapModal(
          content: _.template(openDocTemplate, {documents: documents})
          title: "Open Document"
          animate: true
          showFooter: false
        ).open()
