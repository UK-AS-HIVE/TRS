TRS = @

Template.detail.helpers
  data: ->
    TRS.SemesterDepartmentDetail.findOne {semester: @semester, department: @department}
  persons: ->
    console.log @
    TRS.FacultyAllocations.find {semester: @semester, department: @department},
     {sort: {name: 1} }
  currentlyAllocated: ->
    sanitizePayAmount = (payAmountString) ->
      try
        return parseFloat payAmountString.replace /[^0-9\.-]+/g,""
      catch e
        return 0

    sum = 0.0
    console.log 'Summing allocations...'
    amounts = TRS.FacultyAllocations.find({semester: @semester, department: @department}).forEach (doc) ->
      sum += sanitizePayAmount doc.pay_amount
    return (sum).toFixed(2)

Template.detail.events
  'change #approved-funding-input': (e) ->
    val = $(e.srcElement).val()
    data = TRS.SemesterDepartmentDetail.findOne {semester: @semester, department: @department}
    console.log data
    console.log 'updating to: ' + val
    if data
      TRS.SemesterDepartmentDetail.update {_id: data._id}, {$set: { funding: val } }
    else
      TRS.SemesterDepartmentDetail.insert
        semester: @semester
        department: @department
        funding: val
  'change #comments-textarea': (e) ->
    val = $(e.srcElement).val()
    console.log 'logging comments textarea'
    console.log val
    data = TRS.SemesterDepartmentDetail.findOne {semester: @semester, department: @department}
    if data
      TRS.SemesterDepartmentDetail.update {_id: data._id}, {$set: { comments: val } }
    else
      TRS.SemesterDepartmentDetail.insert
        semester: @semester
        department: @department
        comments: val
  'click .inline-edit .icon-edit': (e) ->
    console.log 'toggle edit'
    toggleEdit(e)
  'click .instructor-details .icon-trash': (e,tpl) ->
    console.log 'removing whole instructor'
    TRS.FacultyAllocations.remove {_id: @_id}
  'click button#add': (e) ->
    console.log @
    TRS.FacultyAllocations.insert
      name: 'Name'
      semester: @semester
      department: @department
      rank: null
      buyout: ''
      pay_amount: ''
      comment: ''
      courses: []
  'change .instructor-properties input, change .pay-amount input': (e) ->
    el = $(e.srcElement)
    prop = el.data 'property'
    setter = {}
    setter[prop] = el.val()
    console.log {_id: @_id}, {$set: setter}
    TRS.FacultyAllocations.update {_id: @_id}, {$set: setter}
  'change .course input': (e,tpl) ->
    edit_form = $(e.srcElement).parents '.inline-edit-form'
    id = edit_form.data 'id'
    index = edit_form.data 'index'
    property = $(e.srcElement).attr 'name'
    val = $(e.srcElement).val()
    setter = {}
    setter['courses.' + index + '.' + property] = val 
    console.log 'set ' + property + ' to ' + val + ' for course #' + index
    TRS.FacultyAllocations.update {_id: id},
      $set: setter
  'click .course .icon-trash': (e,tpl) ->
    course = $(e.currentTarget).parent '.course'
    index = course.data 'index'
    id = $(e.currentTarget).parent('li.course').data 'id'
    console.log 'removing instructor course #' + index
    courses = TRS.FacultyAllocations.findOne({_id: id}).courses
    courses.splice(index, 1)
    TRS.FacultyAllocations.update {_id: id},
      {$set: {courses: courses}}
  'click button.add-course': (e) ->
    console.log @courses.length
    TRS.FacultyAllocations.update {_id: @_id}, {$push: {courses: {prefix:'-', number: '-', credits: 3}}}, {validation: false}
    selector = 'course-'+@_id+'-'+@courses.length
    Session.set 'editing_id', selector
  'keypress .inline-edit-form input': (e) ->
    if e.charCode == 13
      toggleEdit(e)
    

Template.detail.rendered = ->
  template = @

  editingDiv = $('#' + Session.get 'editing_id')
  editingDiv.addClass 'editing'
  if $('input:focus').length == 0
    editingDiv.find('input:first').focus()

  $(@findAll '.editable').editable (value, settings) ->
    console.log 'edited'
    $el = $(@)
    id = $el.data 'id'
    property = $el.data 'property'
    update = {}
    update[property] = value
    TRS.FacultyAllocations.update id, {$set: update }
    value

Template.detailRankSelect.helpers
  selectedOption: (rank) ->
    ret = 'value="' + rank + '"'
    ret += ' selected' if @rank is rank 
    new Handlebars.SafeString ret

Template.detailRankSelect.rendered = ->
  data = @data

  $(@find 'select.rank').select2().change (e) ->
    TRS.FacultyAllocations.update {_id: data._id}, {$set: { rank: e.val }}



toggleEdit = (e) ->
  console.log 'toggle edit'
  parent = $(e.currentTarget).parent '.inline-edit'
  $('.editing').not(parent).removeClass 'editing'
  parent.toggleClass 'editing'
  if parent.hasClass 'editing'
    Session.set 'editing_id', parent.attr 'id'
  else
    Session.set 'editing_id', '' 

