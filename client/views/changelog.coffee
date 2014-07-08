TRS = @

Template.dropDeadChangelog.helpers
  changes: ->
    TRS.DropDeadChanges.find {}, {sort: {timestamp: -1}}

Template.dropDeadChange.rendered = ->
  console.log 'dropDeadChange', @, arguments
  Meteor.setTimeout =>
    $(@.firstNode).fadeOut 600
  , 5000

Template.dropDeadChange.helpers
  formatTime: (timestamp) ->
    console.log timestamp
    return timestamp.getHours() + ':' + timestamp.getMinutes() if timestamp


