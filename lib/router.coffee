TRS = @

Router.configure
  layoutTemplate: 'layoutTemplate'
  #autoRender: false
  waitOn: -> Meteor.subscribe 'admins'
  
Router.map ->
  @route 'home',
    path: '/'
    waitOn: ->
      [Meteor.subscribe 'departments', Meteor.subscribe 'semesters']

  @route 'reportsList',
    path: '/reports'
    waitOn: ->
      Meteor.subscribe 'reports'

  @route 'manage',
    path: '/manage'
    waitOn: ->
      [Meteor.subscribe 'departments', Meteor.subscribe 'semesters']

  @route 'manageDepartments',
    path: '/manage/departments'
    waitOn: ->
      Meteor.subscribe 'departments'

  @route 'manageSemesters',
    path: '/manage/semesters'
    waitOn: ->
      Meteor.subscribe 'semesters'

  # Show a list of semesters to navigate to the detail page
  @route 'department',
    path: '/department/:department'

  @route 'detail',
    path: '/:department/:semester'
    onBeforeAction: ->
      console.log 'onBeforeAction'
      console.log @options
      console.log arguments
      Session.set 'department', @options.params.department
      Session.set 'semester', @options.params.semester
    data: ->
      console.log 'data'
      console.log @
      console.log arguments
      return TRS.SemesterDepartmentDetail.findOne {department: Session.get('department'), semester: Session.get('semester')}
      department: Session.get 'department'
      semester: Session.get 'semester'
    waitOn: ->
      console.log 'Waiting on subscriptions to...'
      console.log @params
      console.log '...'
      [Meteor.subscribe('allocations', @params.department, @params.semester),
       Meteor.subscribe('semesterDepartmentDetail', @params.department, @params.semester),
       Meteor.subscribe('dropDeadChanges', @params.department, @params.semester)]

  @route 'changeLog',
    path: '/:department/:semester/changelog'
    onBeforeAction: ->
      Session.set 'department', @params.department
      Session.set 'semester', @params.semester
      Session.set 'pageLimit', 25
      Session.set 'lastRecord', 0
      Session.set 'sortDir', -1
    waitOn: ->
      [Meteor.subscribe('changelog', @params.department, @params.semester, Session.get('lastRecord'), Session.get('pageLimit'), Session.get('sortDir')), 
       Meteor.subscribe('changeCounts', @params.department, @params.semester)]


  @route 'exportCSV',
    path: '/:department/:semester/csv'
    where: 'server'
    action: (department, semester) ->
      # TODO: server-side permissions check
      # currently may not be easily possible, see https://github.com/EventedMind/iron-router/issues/649
      # therefore, return access denied for now
      #@response.statusCode = 403
      #@response.end 'Export disabled because permissions not yet implemented.'

      console.log 'someone exporting csv', @params
      res = @response
      filename = [
        'TRS',
        @params.department,
        @params.semester,
        moment().format('YY-MM-DD')
      ].join('-').replace(' ','_') + '.csv'
      res.setHeader 'Content-Type', 'text/csv'
      res.setHeader 'Content-Disposition', 'attachment; filename="' + filename + '"'

      TRS.FacultyAllocations.find({department: @params.department, semester: @params.semester}).forEach (d) ->
        courseList = _.map(d.courses, (c) -> [c.prefix, c.number, c.sections].join('-')).join('; ')
        res.write(_.map([d.name, d.rank, d.ukid, d.notes, courseList, d.payAmount(), d.paymentNotes, d.department, d.semester], (s) -> if s? then '"' + s.replace('"','""') + '"').join(',') + "\n")
      res.end()

###
  @route 'detail',
    path: '/d/:department/s/:semester'
    onBeforeAction: ->
      Session.set 'department', @params.department
      Session.set 'semester', @params.semester
    data: ->
      department: Session.get 'department'
      semester: Session.get 'semester'
    waitOn: ->
      console.log 'Waiting on subscriptions to...'
      console.log @
      [(Meteor.subscribe 'allocations', @params.department, @params.semester)
       (Meteor.subscribe 'semesterDepartmentDetail', @params.department, @params.semester)]
###

