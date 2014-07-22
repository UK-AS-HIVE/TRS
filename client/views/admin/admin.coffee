TRS = @

Template.manageDepartments.helpers
  departments: TRS.Departments.find {}, {sort: ['department']}
  users: Meteor.users.find {}

Template.manageDepartments.events
  'click .edit-department': (e) ->
    $(Template.manageDepartmentDialog { department: @department, @chairDMusers }).modal()
  'click #add-department': (e) ->
    bootbox.prompt 'Name of department to add:', (result) ->
      if result? then TRS.Departments.insert { department: result }
  'click .glyphicon-trash': (e) ->
    self = @
    prompt = 'Delete department <em>' + @department + '</em>?'
    bootbox.confirm prompt, (result) ->
      TRS.Departments.remove {_id: self._id} if result is true

Template.departmentUsersSelect.usernames = ->
  if @chairDMusers?
    return @chairDMusers.join ','
  else
    return ''

Template.departmentUsersSelect.rendered = ->
  data = @data
  department_id = @data._id
  $(@.find '.chair-dm-users').select2
    tags: []
    tokenSeparators: [',', ' ', '\n']
    multiple: true
    width: '100%'
    initSelection: (e, cb) ->
      console.log data
      cb $(data.chairDMusers).map (e,o) ->
        {id: o, text: o}
    createSearchChoice: (term) ->
      return {id: term, text: term}
    query: (q) ->
      q.callback
        results: Meteor.users.find({ username: { $regex: '^'+q.term } }).map (doc, index) ->
          {id: doc.username, text: doc.username}
  .change (e) ->
    TRS.Departments.update {_id: department_id}, {$set: {chairDMusers: e.val }}

Template.manageAdmins.usernames = ->
  admins = TRS.Admins.findOne {}
  console.log admins
  if admins?
    return admins.admins.join ','
  else
    return ''

Template.manageAdmins.rendered = ->
  inputBox = $(@.find '.admin-users')
  $(@.find '.admin-users').select2
    tags: []
    tokenSeparators: [',', ' ', '\n']
    multiple: true
    initSelection: (e, cb) ->
      cb _.map e.context.value.split(','), (o) ->
        {id: o, text: o}
    createSearchChoice: (term) ->
      return {id: term, text: term}
    query: (q) ->
      q.callback
        results: Meteor.users.find({ username: { $regex: '^'+q.term } }).map (doc, index) ->
          {id: doc.username, text: doc.username}
  .on 'select2-removing', (e) ->
    if e.val == Meteor.user().username
      e.preventDefault()
      bootbox.confirm 'You are removing yourself from the list of admins.  Doing so may prevent you from making necessary updates.  Are you sure you wish to continue?', (result) ->
        if result is true
          admins = TRS.Admins.findOne {}
          Meteor.call 'upsertAdmins', _.without(admins.admins, e.val)
          return
        else
          admins = TRS.Admins.findOne {}
          if admins?
            inputBox.val(admins.admins.join ',').trigger('change')
  .change (e) ->
    if e.val?
      Meteor.call 'upsertAdmins', e.val

Template.manageDepartmentDialog.helpers
  chairDMUsers: ->
    Meteor.users.find {}

Template.manageDepartmentDialog.rendered = ->
  $('')

Template.manageSemesters.helpers
  semesters: TRS.Semesters.find {}
  priorSemestersExist: ->
    TRS.Semesters.find().count() > 0

Template.manageSemesters.events
  'click #clone_semester': ->
    $('#clone_semester_dialog').modal()
  'click #clone_semester_dialog button#clone': (e) ->
    oldSemesterName = $('#clone_semester_source').val()
    newSemesterName = $('#clone_semester_name').val()
    console.log 'Cloning semester ' + oldSemesterName + ' as ' + newSemesterName
    Meteor.call 'cloneSemester', oldSemesterName, newSemesterName
    $('#clone_semester_dialog').modal('hide')
  'click #clone_semester_dialog button#create': (e) ->
    semesterName = $('#clone_semester_name').val()
    TRS.Semesters.insert { semester: semesterName }
    $('#clone_semester_dialog').modal('hide')
  'click .glyphicon-trash': ->
    self = @
    prompt = 'Delete semester <em>' + @semester + '</em>?'
    bootbox.confirm prompt, (result) ->
      TRS.Semesters.remove {_id: self._id} if result is true



Template.manageSemesters.rendered = ->
  self = @
  data = @data
  $(@.findAll 'input.dropdead').datepicker
    format: 'mm/dd/yy'
  .on 'changeDate', (e) ->
    TRS.Semesters.update { _id: $(e.currentTarget).data 'id'}, {$set: {dropdead: $(e.currentTarget).val() } }
