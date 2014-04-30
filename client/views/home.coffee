TRS = @

Template.home.departments = ->
  TRS.Departments.find {}

Template.home.semesters = ->
  TRS.Semesters.find {}

Template.home.events
  'click button#go': (e, template) ->
    e.preventDefault()

    #Router.go '/s/'+semester+'/d/'+department
    Router.go 'detail',
      semester: $(template.find '#semester-select').val()
      department: $(template.find '#department-select').val()

Template.home.rendered = ->
  $('#semester-select').css('width', $('#department-select').css('width') + 'px');