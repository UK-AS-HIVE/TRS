TRS = @

Template.funding.helpers
  data: ->
    # Ensure that the breakdowns are set
    d = TRS.SemesterDepartmentDetail.findOne
      semester: @semester
      department: @department
    b =
      breakdown: _.map ['GA','TA','RA','PTI','FTI'], (r) ->
        rank: r
        lines: 0
        rate: '0'
    return _.extend b, d
    
Template.funding.events
  'click .inline-edit .icon-edit': toggleEdit
  'keypress .inline-edit-form input': (e) ->
    if e.keyCode == 13
      toggleEdit e
  'change .breakdown-lines input': (e) ->
    edit_form = $(e.target).parents '.inline-edit-form'
    id = edit_form.data 'id'
    index = edit_form.data 'index'
    property = $(e.target).attr 'name'
    val = $(e.target).val()
    setter = {}
    setter['breakdown.' + index + '.' + property] = val 
    console.log 'set ' + property + ' to ' + val + ' for rank ' + index
    return
    TRS.SemesterDepartmentDetail.update {_id: id},
      $set: setter
