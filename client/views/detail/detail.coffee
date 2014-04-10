TRS = @

Template.detail.helpers
  persons: ->
    console.log @
    TRS.FacultyAllocations.find {semester: @semester, department: @department},
     {sort: {name: 1} }
  lineTypes: (context) ->
    console.log 'lineTypes'
    console.log @
    console.log context
    depSem = TRS.SemesterDepartmentDetail.findOne {semester: @semester, department: @department}, {fields: {breakdown: 1}}
    depSem.breakdown
  isFundedByLines: ->
    @rank? and ['GA', 'TA', 'RA', 'PTI', 'FTI'].indexOf(@rank) > -1
  lineValue: (user, lineType) ->
    if user? and user.lines? and user.lines.hasOwnProperty lineType
      console.log user.lines[lineType]
      return user.lines[lineType]
    else
      return 0
  lineFundedSubtotal: (person) ->
    console.log 'linesFundedSubtotal'
    console.log person
    lineRates = TRS.SemesterDepartmentDetail.findOne {semester: person.semester, department: person.department}, {fields: {breakdown: 1}}
    console.log lineRates
    subTotal = 0.0
    if lineRates? && lineRates.breakdown?
      _.each lineRates.breakdown, (b) ->
        try
          subTotal += fractionToFloat(person.lines[b.rank]) * b.rate
        catch e
          console.log 'Error calculating subtotal for person lines'
    '= ' + subTotal.toFixed(2)
  checked: (trueFalse) ->
    if trueFalse then 'checked' else ''
  disabled: (trueFalse) ->
    if trueFalse then '' else 'disabled'
  

Template.detail.events
  'change #approved-funding-input': (e) ->
    val = $(e.target).val()
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
    val = $(e.target).val()
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
    instructorId = @_id
    bootbox.confirm 'Are you sure you wish to delete ' + @name + '?', (confirmed) ->
      if confirmed then TRS.FacultyAllocations.remove {_id: instructorId}
  'click button#add-rank-type': (e) ->
    self = @
    bootbox.prompt 'Name of rank', (result) ->
      if result?
        console.log 'Trying to add ' + result + ' rank'
        data = TRS.SemesterDepartmentDetail.findOne {semester: self.semester, department: self.department}
        if data?
          console.log 'found data, updating it'
          console.log data
          TRS.SemesterDepartmentDetail.update {_id: data._id}, {$push: {breakdown: {lines: 0, rank: result, rate: '0'}}}
        else
          TRS.SemesterDepartmentDetail.insert
            semester: self.semester
            department: self.department
            breakdown: [{lines:0, rank: result, rate: '0'}]
          console.log 'didnt find semesterDepartmentDetail record, inserting'
  'change .breakdown input': (e, tpl) ->
    console.log 'Changed breakdown data'
    edit_form = $(e.target).parents '.inline-edit'
    id = edit_form.data 'id'
    index = edit_form.data 'index'
    property = $(e.target).data 'property'
    val = $(e.target).val()
    setter = {}
    setter['breakdown.' + index + '.' + property] = val
    depSem = TRS.SemesterDepartmentDetail.findOne {semester: tpl.data.semester, department: tpl.data.department}, {fields: {_id: 1}}
    TRS.SemesterDepartmentDetail.update depSem._id,
      $set: setter
  'click .breakdown .icon-trash': (e,tpl) ->
    row = $(e.currentTarget).parents '.breakdown'
    index = row.data 'index'
    #id = $(e.currentTarget).parent('li.course').data 'id'
    console.log 'removing breakdown #' + index
    depSem = TRS.SemesterDepartmentDetail.findOne({semester: tpl.data.semester, department: tpl.data.department}, {fields: {_id:1, breakdown: 1}})
    id = depSem._id
    breakdown = depSem.breakdown
    breakdown.splice(index, 1)
    TRS.SemesterDepartmentDetail.update {_id: id},
      {$set: {breakdown: breakdown}}

  'click button#add': (e) ->
    console.log @
    self = @
    bootbox.prompt 'Name of person to add', (result) ->
      if result?
        TRS.FacultyAllocations.insert
          name: result
          semester: self.semester
          department: self.department
          rank: null
          buyout: null
          pay_amount: ''
          comment: ''
          courses: []
  'change .instructor-properties input, change .pay-amount input': (e) ->
    el = $(e.target)
    prop = el.data 'property'
    setter = {}
    if el.attr('type')=='checkbox'
      console.log el
      setter[prop] = !(el[0].hasAttribute('checked'))
    else
      setter[prop] = el.val()
    id = @_id
    unless id?
      id = el.data 'id'
    console.log {_id: id}, {$set: setter}
    TRS.FacultyAllocations.update {_id: id}, {$set: setter}
  'change .course input': (e,tpl) ->
    edit_form = $(e.target).parents '.inline-edit-form'
    id = edit_form.data 'id'
    index = edit_form.data 'index'
    property = $(e.target).attr 'name'
    val = $(e.target).val()
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
    if e.keyCode == 13
      toggleEdit(e)
  'click #currentlyallocatedbtn': (e) ->
    if Session.get('isExpanded') is true
      Session.set 'isExpanded', false
    else
      Session.set 'isExpanded', true
    

Template.detail.rendered = ->
  template = @

  console.log 'detail template rendered'

  editingDiv = $('#' + Session.get 'editing_id')
  editingDiv.addClass 'editing'
  if $('input:focus').length == 0
    editingDiv.find('input:first').focus()

Template.detailRankSelect.helpers
  selectedOption: (rank) ->
    ret = 'value="' + rank + '"'
    ret += ' selected' if @rank is rank 
    new Handlebars.SafeString ret

Template.detailRankSelect.rendered = ->
  data = @data

  $(@find 'select.rank').select2().change (e) ->
    TRS.FacultyAllocations.update {_id: data._id}, {$set: { rank: e.val }}

