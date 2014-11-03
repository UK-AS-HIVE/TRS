TRS = @

Template.changeLog.helpers
	department: ->
		Session.get 'department'

	semester: ->
		Session.get 'semester'

	changes: ->
		console.log Session.get 'lastRecord'
		TRS.DropDeadChanges.find({}, {skip: Session.get('lastRecord'), limit: Session.get('pageLimit')})

Template.changeLog.events
	'click #nextChangesPage': ->
		last = Session.get 'lastRecord'
		last = last + Session.get 'pageLimit'
		if last <= TRS.DropDeadChanges.find().count()
			Session.set 'lastRecord', last

	'click #previousChangesPage': ->
		last = Session.get 'lastRecord'
		if last > 0
			Session.set 'lastRecord', last - Session.get 'pageLimit'