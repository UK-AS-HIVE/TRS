inline-edit
===========

This smart package adds functionality to standardize a way to edit lists of
data, related to Meteor collections.

Usage
-----
In your templates, define divs that have both a preview component and a form for
editing the values.  The outermost component must have a unique id attribute.

    <div class="inline-edit" id="editable-databound-feature-{{_id}}">
      <span class="inline-edit-preview">Current value: {{value}}</span>
      <span class="inline-edit-form">
        <input id="my-input" type="text" value="{{value}}"/>
      </span>
      <i class="icon-edit"></i>
    </div>
    
TODO: Adding and deleting items
TODO: Template event handlers
TODO: Editable subdocuments
