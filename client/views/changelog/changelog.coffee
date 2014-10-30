TRS = @

Template.changeLog.helpers
	department: ->
		Session.get 'department'

	semester: ->
		Session.get 'semester'

	changes: ->
		TRS.DropDeadChanges.find()