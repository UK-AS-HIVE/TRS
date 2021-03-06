TRS = @

Template.detail.helpers
  persons: ->
    console.log @
    where = {semester: Session.get('semester'), department: Session.get('department')}
    Session.setDefault 'currentRankFilter', ['All']
    rankFilter = Session.get('currentRankFilter')
    if rankFilter.length > 0 and rankFilter[0] != 'All'
      where.rank = {$in: rankFilter}
    TRS.FacultyAllocations.find where, {sort: {name: 1} }
  lineTypes: (context) ->
    console.log 'lineTypes'
    console.log @
    console.log context
    depSem = TRS.SemesterDepartmentDetail.findOne {semester: Session.get('semester'), department: Session.get('department')}, {fields: {breakdown: 1}}
    if depSem?
      depSem.breakdown
  isFundedByLines: ->
    @rank? and ['GA', 'TA', 'RA', 'PTI', 'FTI'].indexOf(@rank) > -1
  lineValue: (user, lineType) ->
    if user? and user.lines? and user.lines.hasOwnProperty lineType
      console.log user.lines[lineType]
      return user.lines[lineType]
    else
      return 0
  checked: (trueFalse) ->
    if trueFalse then 'checked' else null
  disabled: (trueFalse) ->
    if trueFalse then null else 'disabled'
  plain_text: (s) -> new Spacebars.SafeString (s.replace /\n/g, '<br/>')

Template.detail.events
  'change #comments-textarea': (e) ->
    val = $(e.target).val()
    console.log 'logging comments textarea'
    console.log val
    sem = Session.get 'semester'
    dep = Session.get 'department'
    data = TRS.SemesterDepartmentDetail.findOne {semester: sem, department: dep}
    if data
      TRS.SemesterDepartmentDetail.update {_id: data._id}, {$set: { comments: val } }
    else
      TRS.SemesterDepartmentDetail.insert
        semester: sem
        department: dep
        comments: val
  'click .inline-edit .glyphicon-edit': (e) ->
    console.log 'toggle edit'
    toggleEdit(e)
  'click .instructor-details .glyphicon-trash': (e,tpl) ->
    console.log 'removing whole instructor'
    instructorId = @_id
    bootbox.confirm 'Are you sure you wish to delete ' + @name + '?', (confirmed) ->
      if confirmed then TRS.FacultyAllocations.remove {_id: instructorId}
  
  'click button#add': (e) ->
    console.log @
    self = @
    bootbox.prompt 'Name of person to add (last, first)', (result) ->
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
  'change .instructor-properties input, change .instructor-properties textarea, change .pay-amount input, change .pay-amount textarea': (e) ->
    el = $(e.target)
    prop = el.data 'property'
    setter = {}
    if el.attr('type')=='checkbox'
      console.log el
      setter[prop] = el[0].checked
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
  'click .course .glyphicon-trash': (e,tpl) ->
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
    new Spacebars.SafeString ' selected' if @rank is rank

Template.detailRankSelect.rendered = ->
  data = @data

  $(@find 'select.rank').select2().change (e) ->
    TRS.FacultyAllocations.update {_id: data._id}, {$set: { rank: e.val }}

Template.detailFilter.helpers
  selectedOption: (rank) ->
    currentRankFilter = Session.get 'currentRankFilter'
    if currentRankFilter? and currentRankFilter.indexOf(rank) > -1
      return new Spacebars.SafeString ' selected'

Template.detailFilter.events
  'change select': (e,tpl) ->
    Session.set 'currentRankFilter', $(tpl.find('select')).val()

