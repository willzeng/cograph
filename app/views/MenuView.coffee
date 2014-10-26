define ['jquery', 'underscore', 'backbone', 'bloodhound', 'typeahead', 'bootstrap',
 'bb-modal', 'text!templates/new_doc_modal.html', 'text!templates/open_doc_modal.html',
 'text!templates/analytics_modal.html', 'text!templates/workspaces_menu_modal.html',
 'cs!models/DocumentModel', 'socket-io', 'text!templates/graph_settings.html'],
  ($, _, Backbone, Bloodhound, typeahead, bootstrap, bbModal, newDocTemplate, openDocTemplate, analyticsTemplate, workspacesMenuTemplate, DocumentModel, io, openSettingsTemplate) ->
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
        'click #settings-button': 'openSettingsModal'
        'click .public-button-display': 'openSettingsModal'
        'click #save-graph-settings': 'saveSettings'
        'click .public-button-view': 'publicViewChange'
        'click .public-button-edit': 'publicEditChange'
        'click #maybe-publish-button': 'openSettingsModal'

      initialize: ->
        @model.on "document:change", @render, this
        @model.getDocument().on 'change', @render, this
        @model.getDocument().on 'change:public', @updatePublicButton, this
        @render()

      render: ->
        @updateTitle()
        @updatePublicButton()
        @updatePublishButton()

      updatePublishButton: ->
        if @model.getDocument().get("publicView") is 0 or @model.getDocument().get("publicView") is 1
          $('#maybe-publish-button').html "<a class='clickable'>Publish</a>"
        else if($('.public-button-display').hasClass('clickable')) #isOwner
          $('#maybe-publish-button').html "<a class='clickable'>Settings</a>"
        else 
          $('#maybe-publish-button').html ""

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

      openSettingsModal: ->
        if($('.public-button-display').hasClass('clickable')) #isOwner
          name = @model.getDocument().get("name")
          canPublicView = @model.getDocument().get("publicView")
          canPublicEdit = @model.getDocument().get("publicEdit")
          @openSettingsModal = new Backbone.BootstrapModal(
            content: _.template(openSettingsTemplate, {name:name, canPublicView:canPublicView, canPublicEdit:canPublicEdit, embed:@getEmbed(window.location.href)})
            title: "Graph Settings"
            animate: true
            showFooter: false
          ).open()

      publicViewChange: (e) ->
        $('.public-button-view').removeClass('selected')
        $(e.currentTarget).addClass('selected')

      publicEditChange: (e) ->
        $('.public-button-edit').removeClass('selected')
        $(e.currentTarget).addClass('selected')

      saveSettings: ->
        doc = @model.getDocument()
        doc.set 'name', $('#menu-title').val()
        newViewState = $('.public-button-view.selected').data('type')
        newEditState = $('.public-button-edit.selected').data('type')
        doc.set "publicView", newViewState
        doc.set "publicEdit", newEditState
        doc.save()
        @openSettingsModal.close()
        @updateTitle()
        @updatePublicButton()
        @updatePublishButton()

      updatePublicButton: ->
        if @model.getDocument().get('publicView') != 0
          $('.public-button-display').html '<i class="fa fa-globe" title="public"></i>'
        else
          $('.public-button-display').html '<i class="fa fa-lock" title="private"></i>'

      updateTitle: ->
        $('#menu-title-display').text @model.getDocument().get('name')
        $('.navbar-doc-title').css('left', 'calc(50% - '+$(".navbar-doc-title").width()/2+'px')

      # NOTE: THIS IS CURRENTLY UNUSED
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

      getEmbed: (url) ->
        """
        <div style='min-width:420;max-width:700'>
          <iframe src='#{url}' width='100%' height='100%'
          scrolling='no' frameborder='0' allowfullscreen>
          </iframe>
        </div>
        """

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
