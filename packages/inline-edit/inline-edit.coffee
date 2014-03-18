EditingLocks = new Meteor.Collection 'editingLocks'

if Meteor.isServer
  Meteor.publish 'editingLocks', ->
    EditingLocks.find()

  Meteor.methods
    startEditing: (id) ->
      console.log 'somebody ' + @userId + ' started editing ' + id
      EditingLocks.remove {'user': @userId}
      EditingLocks.insert
        user: @userId
        editing_id: id
      
    stopEditing: (id) ->
      EditingLocks.remove {'user': @userId, 'editing_id': id}

(exports ? this).toggleEdit = (e) -> 
  console.log 'toggle edit'
  parent = $(e.currentTarget).parent '.inline-edit'
  $('.editing').not(parent).removeClass 'editing'
  parent.toggleClass 'editing'
  console.log 'parent id: ' + (parent.attr 'id')
  if parent.hasClass 'editing'
    Meteor.call 'startEditing', parent.attr 'id'
    Session.set 'editing_id', parent.attr 'id'
  else
    Meteor.call 'stopEditing', parent.attr 'id'
    Session.set 'editing_id', '' 

if Meteor.isClient
  Meteor.startup ->
    Deps.autorun ->
      Meteor.subscribe 'editingLocks', ->
        EditingLocks.find({user: Meteor.userId()}).observe
          added: (doc) ->
            console.log 'added lock on ' + doc.editing_id
            #Session.set 'editing_id', doc.editing_id
          removed: (doc) ->
            console.log 'removed lock on ' + doc.editing_id
            #Session.set 'editing_id', ''

  Handlebars.registerHelper 'inlineEditLock', (context, options) ->
    console.log 'inlineEditLock'
    editing_id = @_id
    if context.hash.prefix? then editing_id = context.hash.prefix + editing_id
    lock = EditingLocks.findOne {editing_id: editing_id}
    if lock?
      editor = Meteor.users.findOne({_id: lock.user})
      #return new Handlebars.SafeString(Template._inlineEditLock())
      return new Handlebars.SafeString('<span class="pull-right"><i class="icon-lock"></i>'+editor.username+'</span>')
    else
      return ''
