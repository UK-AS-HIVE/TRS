EditingLocks = new Meteor.Collection 'editingLocks'

if Meteor.isServer
  Meteor.onConnection (connection) ->
    console.log ['new connection'].concat(_.values connection.httpHeaders).join ' - '
    connection.onClose = ->
      #TODO: this never gets called.  consider using mizzao:user-status
      console.log 'Connection closed:'
      console.log @
      EditingLocks.remove {connection: @id}

  Meteor.startup ->
    EditingLocks.remove {}

  Meteor.publish 'editingLocks', ->
    console.log ['subscribing to editingLocks', @userId].concat(_.values @connection.httpHeaders).join ' - '
    EditingLocks.find()

  Meteor.methods
    startEditing: (id) ->
      console.log ['locked ' + id, @userId].concat(_.values @connection.httpHeaders).join ' - '
      EditingLocks.remove {connection: @connection.id}
      EditingLocks.insert
        user: @userId
        connection: @connection.id
        editing_id: id
      
    stopEditing: (id) ->
      console.log ['unlocked ' + id, @userId].concat(_.values @connection.httpHeaders).join ' - '
      EditingLocks.remove {connection: @connection.id, user: @userId, 'editing_id': id}

(exports ? this).toggleEdit = (e) -> 
  #console.log 'toggle edit'
  parent = $(e.target).parents '.inline-edit'
  $('.editing').not(parent).removeClass 'editing'
  parent.toggleClass 'editing'
  #console.log e
  #console.log 'parent id: ' + (parent.attr 'id')
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

  UI.registerHelper 'inlineEditLock', (context, options) ->
    #console.log 'inlineEditLock'
    #console.log @
    #console.log context
    #console.log options
    editing_id = @_id
    if context.hash.prefix? then editing_id = context.hash.prefix + editing_id
    lock = EditingLocks.findOne {editing_id: editing_id}
    if lock?
      editor = Meteor.users.findOne({_id: lock.user})
      #return new Spacebars.SafeString(Template._inlineEditLock())
      return new Spacebars.SafeString('<span class="pull-right"><i class="glyphicon glyphicon-lock"></i>'+editor.username+'</span>')
    else
      return ''

  UI.registerHelper 'inlineEditLocked', (context, options) ->
    editing_id = @_id
    if context.hash.prefix? then editing_id = context.hash.prefix + editing_id
    lock = EditingLocks.findOne {editing_id: editing_id}
    lock?

  # {{{inlineEditBackground prefix="inline-edit-container-id-" bgcolor="blue"}}}
  UI.registerHelper 'inlineEditBackground', (context, options) ->
    editing_id = @_id
    if context.hash.prefix? then editing_id = context.hash.prefix + editing_id
    lock = EditingLocks.findOne {editing_id: editing_id}
    if lock?
      return 'background: '+context.hash.bgcolor+';'
    else
      return ''

