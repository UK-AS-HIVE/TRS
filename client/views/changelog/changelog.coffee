TRS = @

@ChangeCount = new Meteor.Collection('change-count')


Template.changeLog.helpers
  department: ->
    Session.get 'department'

  semester: ->
    Session.get 'semester'

  changes: ->
    TRS.DropDeadChanges.find({})

Template.changeLog.events
  'click .next': ->
    last = Session.get 'lastRecord'
    last = last + Session.get 'pageLimit'
    if last <= TRS.ChangeCount.findOne()['count']
      Session.set 'lastRecord', last

  'click .previous': ->
    last = Session.get 'lastRecord'
    if last > 0
      Session.set 'lastRecord', last - Session.get 'pageLimit'

