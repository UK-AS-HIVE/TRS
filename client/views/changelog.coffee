TRS = @
exports = this 
exports.hideChangesTimeout #needed to have 1 setTimeOut reference. Timeout resets when new change is in.

Template.dropDeadChangelog.helpers
  changes: ->
    TRS.DropDeadChanges.find {}, {sort: {timestamp: -1}}

Deps.autorun ->
  DropDeadChanges.find().observeChanges added: (id, doc) ->
    console.log("New Change")
    clearTimeout(exports.hideChangesTimeout)
    $('#dropDeadChangelog').fadeIn(600);
    exports.hideChangesTimeout = setTimeout ->
      $('#dropDeadChangelog').fadeOut(600);
    , 5000

UI.registerHelper "formatTime", (timestamp) ->
  console.log timestamp
  return timestamp.getHours() + ':' + timestamp.getMinutes() if timestamp


