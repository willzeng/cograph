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
      el: $ 'body'

      events:
        'click #new-doc-button': 'newDocumentModal'
        'click #open-doc-button': 'openDocumentModal'
        'click #analytics-button': 'openAnalyticsModal'
        'click #workspaces-button': 'openWorkspacesModal'

      initialize: ->
        @model.on "document:change", @render, this
        @model.getDocument().on 'change', @render, this
        @menuTitle = $('#menu-title')

        @menuTitle.tooltip({animation:true})
        @menuTitle.click( ()->
           $(this).select()
        )
        @menuTitle.bind 'blur', () =>
          @model.getDocument().set 'name', @menuTitle.val()
          @model.getDocument().save()
        @menuTitle.keydown( (e) =>
          if(e.which == 13)
            @menuTitle.trigger 'blur'
        )
        @render()

      render: ->
        $('#menu-title').val @model.getDocument().get('name')

      newDocumentModal: ->
        @newDocModal = new Backbone.BootstrapModal(
          content: _.template(newDocTemplate, {})
          title: "New Cograph"
          animate: true
          showFooter: false
        ).open()

        @newDocModal.on "shown", () ->
          $('#newDocName').focus()
          $("#new-doc-form").submit (e) ->
            false

        $('#new-doc-form', @newDocModal.$el).click () =>
          @newDocument()
          @newDocModal.close()

      newDocument: () ->
        docName = $('#newDocName', @newDocModal.el).val()
        newDocument = new DocumentModel(name: docName)
        $.when(newDocument.save()).then =>
          if window.user?
            name = window.user.local.name
            window.open "/#{name}/document/"+newDocument.get('_id'), "_blank"
          else
            window.open '/'+newDocument.get('_id'), "_blank"

      openDocumentModal: ->
        user = window.user
        documents = new DocumentCollection
        if user?
          data = {documentIds: user.documents}
        else
          data = {}
        $.when(documents.fetch({data: data})).then =>
          modal = new Backbone.BootstrapModal(
            content: _.template(openDocTemplate, {documents: documents})
            title: "Open Cograph"
            animate: true
            showFooter: false
          ).open()
        false # prevent navigation from appending '#'

      openAnalyticsModal: ->
        @model.getDocument().getAnalytics (analyticsData) ->
          modal = new Backbone.BootstrapModal(
            content: _.template(analyticsTemplate, analyticsData)
            title: "Stats"
            animate: true
            showFooter: false
          ).open()
        false # prevent navigation from appending '#'

      openWorkspacesModal: ->
        docId = @model.getDocument().get("_id")
        workspaces = @model.getDocument().get("workspaces")
        createdBy = @model.getDocument().get("createdBy")
        modal = new Backbone.BootstrapModal(
          content: _.template(workspacesMenuTemplate, {docId:docId, workspaces:workspaces, createdBy: createdBy})
          title: "Open View"
          animate: true
          showFooter: false
        ).open()

        modal.on 'shown', () =>
          $('.delete-workspace').on 'click', (e) =>
            e.preventDefault()
            @model.deleteWorkspace $(e.currentTarget).attr('data-id'), (id) =>
              modal.close()

        false # prevent navigation from appending '#'
