
Router.configure
  autoRender: false

Router.map ->
  @route 'home',
    path: '/',
    waitOn: ->
      [Meteor.subscribe 'departments', Meteor.subscribe 'semesters']

  @route 'reportsList',
    path: '/reports'
    waitOn: ->
      Meteor.subscribe 'reports'

  @route 'manage',
    path: '/manage'

  @route 'manageDepartments',
    path: '/manage/departments'
    waitOn: ->
      Meteor.subscribe 'departments'

  @route 'manageSemesters',
    path: '/manage/semesters'

  # Show a list of semesters to navigate to the detail page
  @route 'department',
    path: '/department/:department'

  @route 'detail',
    path: '/s/:semester/d/:department'
    before: ->
      Session.set 'department', @params.department
      Session.set 'semester', @params.semester
    data: ->
      department: Session.get 'department'
      semester: Session.get 'semester'

  @route 'detail',
    path: '/d/:department/s/:semester'
    before: ->
      Session.set 'department', @params.department
      Session.set 'semester', @params.semester
    data: ->
      department: Session.get 'department'
      semester: Session.get 'semester'

