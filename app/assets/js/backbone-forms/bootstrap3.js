/**
 * Include this template file after backbone-forms.amd.js to override the default templates
 *
 * 'data-*' attributes control where elements are placed
 */
define(['jquery', 'underscore', 'backbone', 'backbone-forms'], function($, _, Backbone) {
  var Form = Backbone.Form;


  /**
   * Bootstrap 3 templates
   */
  Form.template = _.template('\
    <form role="form" data-fieldsets></form>\
  ');


  Form.Fieldset.template = _.template('\
    <fieldset data-fields>\
      <% if (legend) { %>\
        <legend><%= legend %></legend>\
      <% } %>\
    </fieldset>\
  ');


  Form.Field.template = _.template('\
    <div class="form-group field-<%= key %> edit-details-form">\
      <label class="control-label" for="<%= editorId %>"><%= title %></label>\
      <div>\
        <span data-editor></span>\
        <span class="help-block" data-error></span>\
        <span class="help-block"><%= help %></span>\
      </div>\
    </div>\
  ');


  Form.NestedField.template = _.template('\
    <div class="field-<%= key %>">\
      <div title="<%= title %>" class="input-xlarge">\
        <span data-editor></span>\
        <div class="help-inline" data-error></div>\
      </div>\
      <div class="help-block"><%= help %></div>\
    </div>\
  ');

  Form.editors.Base.prototype.className = 'form-control';
  Form.Field.errorClassName = 'has-error';


  if (Form.editors.List) {

    Form.editors.List.template = _.template('\
      <div class="bbf-list">\
        <ul class="list-unstyled clearfix" data-items></ul>\
        <button type="button" class="btn bbf-add" data-action="add">Add</button>\
      </div>\
    ');


    Form.editors.List.Item.template = _.template('\
      <li class="clearfix">\
        <span class="pull-left" data-editor></span>\
        <button type="button" class="btn bbf-del" data-action="remove">&times;</button>\
      </li>\
    ');


    Form.editors.List.Object.template = Form.editors.List.NestedModel.template = _.template('\
      <div class="bbf-list-modal"><%= summary %></div>\
    ');

  }


});
