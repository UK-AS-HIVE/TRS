TRS = @

Template.detail.helpers
  persons: ->
    console.log @
    TRS.FacultyAllocations.find {semester: @semester, department: @department}

Template.detail.events
  'click .inline-edit .icon-edit': (e) ->
    console.log 'toggle edit'
    parent = $(e.currentTarget).parent '.inline-edit'
    $('.editing').not(parent).removeClass 'editing'
    parent.toggleClass 'editing'
    if parent.hasClass 'editing'
      Session.set 'editing_id', parent.attr 'id'
    else
      Session.set 'editing_id', ''
  'click .instructor-details .icon-trash': (e,tpl) ->
    console.log 'removing whole instructor'
    TRS.FacultyAllocations.remove {_id: @_id}
  'click button#add': (e) ->
    console.log @
    TRS.FacultyAllocations.insert
      name: 'click to edit'
      semester: @semester
      department: @department
      rank: 'unspecified'
      buyout: ''
      pay_amount: ''
      comment: ''
      courses: []
  'change .instructor-properties input': (e) ->
    el = $(e.srcElement)
    prop = el.data 'property'
    setter = {}
    setter[prop] = el.val()
    TRS.FacultyAllocations.update {_id: @_id}, {$set: setter}
  'change .course input': (e,tpl) ->
    edit_form = $(e.srcElement).parent '.inline-edit-form'
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
    unset = {}
    unset['courses.'+index] = 1
    id = $(e.currentTarget).parent('li.course').data 'id'
    console.log 'removing instructor course #' + index
    console.log tpl
    TRS.FacultyAllocations.update {_id: id}, {$unset: unset}
    TRS.FacultyAllocations.update {_id: id}, {$pull: {courses: null}}
  'click button.add-course': (e) ->
    console.log @
    TRS.FacultyAllocations.update {_id: @_id}, {$push: {courses: {prefix:'', number: '', credits: ''}}}

Template.detail.rendered = ->
  template = @

  $('#' + Session.get 'editing_id').addClass 'editing'

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
