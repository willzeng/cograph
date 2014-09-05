define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'bootstrap',
 'bb-modal', 'text!templates/new_doc_modal.html', 'text!templates/open_doc_modal.html',
 'text!templates/analytics_modal.html', 'text!templates/workspaces_menu_modal.html',
 'cs!models/DocumentModel', 'socket-io'],
  ($, _, Backbone, Bloodhound, typeahead, bootstrap, bbModal, newDocTemplate, openDocTemplate, analyticsTemplate, workspacesMenuTemplate, DocumentModel, io) ->
    class DocumentCollection extends Backbone.Collection
      model: DocumentModel
      url: 'documents'
      socket: io.connect('')

    class MenuView extends Backbone.View
      el: $ '#sidebar'

      events:
        'click #new-doc-button': 'newDocumentModal'
        'click #open-doc-button': 'openDocumentModal'
        'click #analytics-button': 'openAnalyticsModal'
        'click #workspaces-button': 'openWorkspacesModal'

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
        false # prevent navigation from appending '#'

      openWorkspacesModal: ->
        docId = @model.getDocument().get("_id")
        workspaces = @model.getDocument().get("workspaces")
        modal = new Backbone.BootstrapModal(
          content: _.template(workspacesMenuTemplate, {docId:docId, workspaces:workspaces})
          title: "Workspaces"
          animate: true
          showFooter: false
        ).open()

        modal.on 'shown', () =>
          $('.delete-workspace').on 'click', (e) =>
            e.preventDefault()
            @model.deleteWorkspace $(e.currentTarget).attr('data-id'), (id) =>
              modal.close()
              @model.getDocument().set "workspaces", _.filter(workspaces, (x) -> return parseInt(x) != parseInt(id))

        false # prevent navigation from appending '#'
