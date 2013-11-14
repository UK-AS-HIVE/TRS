
Router.configure
  autoRender: false

Router.map ->
  @route 'manage',
    path: '/'

  @route 'reportsList',
    path: '/reports'
    waitOn: ->
      Meteor.subscribe 'reports'

  #@route 'users',
  #  path: '/users'

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
    path: '/detail/:semester/:department'
