TRS = @

Template.dropDeadChangelog.helpers
  changes: ->
    TRS.DropDeadChanges.find {}, {sort: {timestamp: -1}}

Template.dropDeadChange.rendered = ->
  console.log 'dropDeadChange', @, arguments
  Meteor.setTimeout =>
    $(@.firstNode).fadeOut 600
  , 2500

Template.dropDeadChange.helpers
  formatTime: (timestamp) ->
    console.log timestamp
    moment(timestamp).format 'h:mm'
